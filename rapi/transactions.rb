module Monthly
  module Rapi

    class Transactions
      def self.create_and_refund(transaction)
        uuid = Helpers.recurly_refund(transaction.invoice, transaction.amount)
        transaction.action = :refund # This is the only transaction type we currently support
        transaction.recurly_code = uuid
        transaction.save(validate:false)
      end

      module Helpers
        module_function

        def recurly_refund(invoice, amount_in_usd)
          amount_in_cents = Rapi::Utils::convert_to_cents(amount_in_usd)
          rt = recurly_find_transaction(invoice)
          rt.refund(amount_in_cents)
          rt.uuid
        end

        def recurly_find_transaction(invoice)
          rth = ::Recurly::Invoice.find(invoice.invoice_number).transactions.first
          Recurly::Transaction.find(rth['uuid'])
        end

      end
    end

  end
end
