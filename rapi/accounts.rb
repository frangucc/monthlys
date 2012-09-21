require_relative 'utils.rb'

module Monthly
  module Rapi

    class Accounts
      # Assumes saved valid user.
      def self.sync(user)
        if user.recurly_code.empty?
          recurly_code = Rapi::Utils.ucode(user.id)
          Helpers.recurly_create_account(user, recurly_code)
          user.recurly_code = recurly_code
          user.save(validate: false)
        else
          Helpers.recurly_update_account(user)
        end

        user
      end

      def self.close(user)
        Helpers.recurly_destroy_account(user)
        user.is_active = false
        user.save(validate: false)
        user.subscriptions.has_state(:active).update_all(state: 'canceled')
      end

      def self.reopen(user)
        Helpers.recurly_reopen_account(user)
        user.is_active = true
        user.save(validate: false)
      end

      def self.billing_info(user)
        Helpers.recurly_billing_info(user)
      end

      def self.destroy_billing_info(user)
        Helpers.recurly_destroy_billing_info(user)
      end

      def self.recurly_account(user)
        Helpers.recurly_find_account(user)
      end

      module Helpers
        module_function

        def user_for_recurly_account(raccount)
          User.where(recurly_code: raccount.account_code).first
        end

        def recurly_create_account(user, recurly_code)
          params = account_recurly_params(user, { account_code: recurly_code })
          ::Recurly::Account.create!(params)
        end

        def recurly_update_account(user)
          recurly_find_account(user).update_attributes!(account_recurly_params(user))
        end

        def recurly_find_account(user)
          ::Recurly::Account.find(user.recurly_code)
        end

        def recurly_send_account(user, action)
          recurly_find_account(user).send(action)
        end

        def recurly_destroy_account(user)
          recurly_send_account(user, :destroy)
        end

        def recurly_reopen_account(user)
          recurly_send_account(user, :reopen)
        end

        def recurly_billing_info(user)
          recurly_send_account(user, :billing_info)
        end

        def recurly_destroy_billing_info(user)
          raccount = recurly_find_account(user)
          if billing_info = raccount.billing_info
            billing_info.destroy
          end
        end

        def account_recurly_params(user, extra = {})
          {
            email: user.email,
            username: user.email,
            first_name: user.first_name,
            last_name: user.last_name
          }.merge(extra)
        end
      end
    end

  end
end
