module Monthly
  module Rapi

    class Invoices

      COLLECTED_STATE = 'collected'

      def self.sync_last_for_account(raccount, count = 1)
        rinvoice = raccount.invoices.paginate(per_page: 1).find_each.next
        invoice = Invoice.find_by_invoice_number(rinvoice.invoice_number) || Invoice.new
        Helpers.update(invoice, rinvoice)
      end

      def self.fetch_and_update(invoice_number)
        rinvoice = Helpers.recurly_find_invoice(invoice_number)
        invoice = Invoice.find_by_invoice_number(invoice_number) || Invoice.new
        Helpers.update(invoice, rinvoice)
      end

      def self.sync(invoice)
        rinvoice = Helpers.recurly_find_invoice(invoice.invoice_number)
        Helpers.update(invoice, rinvoice)
      end

      # Creates new recurly invoices on the system.
      #
      # TODO: Figure out how we could take advantage of
      #       pagination/cursor param to make this more efficient.
      def self.create_new
        last_synced = Registry.find_by_key(:last_synced_invoice_number)
        min_num = Monthly::Config::RECURLY_MIN_INVOICE_NUMBER - 1
        last_synced_number = last_synced ? last_synced.value.to_i : min_num
        batch_start_number = nil

        Recurly::Invoice.find_each do |rinvoice|
          break if rinvoice.invoice_number == last_synced_number

          batch_start_number = rinvoice.invoice_number if batch_start_number.nil?

          if !Invoice.where(invoice_number: rinvoice.invoice_number).first
            Helpers.update(Invoice.new, rinvoice)
          end
        end

        if batch_start_number
          if last_synced
            last_synced.update_attributes(value: batch_start_number)
          else
            Registry.create(key: :last_synced_invoice_number,
                            value: batch_start_number)
          end
        end
      end

      def self.update_subscriptions_past_due(invoice)
        if invoice.status == 'past_due'
          invoice.subscriptions.update_all(is_past_due: true)
        elsif invoice.status == 'collected'
          invoice.subscriptions.update_all(is_past_due: false)
        end
      end

      module Helpers
        module_function

        def recurly_find_invoice(invoice_number)
          ::Recurly::Invoice.find(invoice_number)
        end

        def update(invoice, rinvoice)
          ActiveRecord::Base.transaction do
            user = Rapi::Accounts::Helpers::user_for_recurly_account(rinvoice.account)

            invoice.user = user
            invoice.uuid = rinvoice.uuid
            invoice.status = rinvoice.state
            invoice.subtotal_in_usd = Rapi::Utils.convert_to_usd(rinvoice.subtotal_in_cents)
            invoice.total_in_usd = Rapi::Utils.convert_to_usd(rinvoice.total_in_cents)
            invoice.invoice_number = rinvoice.invoice_number
            invoice.save(validate: false)

            subscription_refs = {}

            rinvoice.line_items.each do |radj|
              line = invoice.invoice_lines.find_by_uuid(radj['uuid']) || invoice.invoice_lines.new

              %W(uuid description origin quantity start_date
                 end_date).each { |f| line.send("#{f}=", radj[f]) }
              line.unit_amount_in_usd = Rapi::Utils.convert_to_usd(radj['unit_amount_in_cents'])
              line.discount_in_usd = Rapi::Utils.convert_to_usd(radj['discount_in_cents'])
              line.recurly_created_at = radj['created_at']

              if user && line.origin == 'plan' && (acode = radj['accounting_code'])
                unless subscription_refs.has_key?(acode)
                  pr = PlanRecurrence.find_by_recurly_plan_code(acode)
                  subscription_refs[acode] = (pr) ? user.subscriptions.where(plan_recurrence_id: pr.id).last_subscription : nil
                end

                line.subscription = subscription_refs[acode] if subscription_refs[acode]
              end

              line.save(validate: false)
            end

            subscriptions = subscription_refs.values.reject{ |i| i.nil? }
            unless subscriptions.empty?
              if invoice.status == COLLECTED_STATE
                successful_transaction = rinvoice.transactions.find {|t| t['status'] == 'success' }
                billing_info = successful_transaction['details']['account']['billing_info']

                cc_last_four = billing_info['last_four']
                cc_type = billing_info['card_type']
                cc_exp_date = "#{billing_info['month']}/#{billing_info['year']}"

                Subscription.where(id: subscriptions.map(&:id)).update_all({
                  cc_last_four: cc_last_four,
                  cc_type: cc_type,
                  cc_exp_date: cc_exp_date
                })
              end
              invoice.subscriptions = subscriptions
              invoice.save(validate: false)
            end
          end

          invoice
        end
      end
    end
  end
end
