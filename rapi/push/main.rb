require 'recurly'
require 'sinatra'
require 'nokogiri'
require_relative '../config.rb'


module Monthly
  module Rapi
    module Push

      class Main < Sinatra::Base
        post '/notifications' do
          doc = Nokogiri(request.body.read)
          notification = doc.root.name
          halt 403 unless notifications.include?(notification)
          self.send(notification, doc)
        end

        helpers do
          def notifications
            [ 'expired_subscription_notification',
              'successful_payment_notification',
              'failed_payment_notification',
              'renewed_subscription_notification'
            ]
          end

          def bad_request(msg = 'Invalid XML')
            halt(400, msg)
          end

          # Handler helpers

          def payment_sync_invoice(doc)
            transaction = doc.at('transaction') || bad_request
            invoice = transaction.at('invoice_id') || bad_request
            return if invoice.text.empty?

            invoice = Invoice.find_by_uuid(invoice.text)
            if invoice
              Rapi::Invoices.sync(invoice)
              Rapi::Invoices.update_subscriptions_past_due(invoice)
            end

            invoice
          end

          def subscription_from_doc(doc)
            subscription = doc.at('subscription') || bad_request
            uuid_node = subscription.at('uuid') || bad_request

            uuid = uuid_node.text
            ::Recurly::Subscription.find(uuid)
          end

          # Notification handlers

          def expired_subscription_notification(doc)
            rsubscription = subscription_from_doc(doc)
            if rsubscription.state == 'expired'
              subscription = Subscription.find_by_recurly_code(rsubscription.uuid)
              subscription.state = 'expired'
              subscription.expired_at = rsubscription.expires_at
              subscription.save(validate: false)
            end
          end

          def successful_payment_notification(doc)
            invoice = payment_sync_invoice(doc)

            doc_transaction = doc.at('transaction') || bad_request
            transaction_uuid = doc_transaction.at('id') || bad_request
            rtransaction = Recurly::Transaction.find(transaction_uuid.text)

            last_payment_date = rtransaction.created_at
            last_payment_amount = Rapi::Utils.convert_to_usd(rtransaction.amount_in_cents)

            if invoice && transaction.invoice && rtransaction.invoice.invoice_number == invoice.invoice_number
              invoice.subscriptions.update_all(last_payment_date: last_payment_date, last_payment_amount: last_payment_amount)
            end
          end

          def failed_payment_notification(doc)
            payment_sync_invoice(doc)
          end

          def renewed_subscription_notification(doc)
            subscription = doc.at('subscription') || bad_request
            uuid_node = subscription.at('uuid') || bad_request

            subscription = Subscription.find_by_recurly_code(uuid_node.text)
            Rapi::Subscriptions.update_current_period(subscription) if subscription
          end

        end
      end

    end
  end
end
