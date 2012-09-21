module Monthly
  module Rapi

    class Subscriptions
      # Creates a new subsciption, inserts the corresponding new Subscription
      # on the application db and creates the Subscription on Recurly.
      # params.
      #
      # If the subscription can't be created on recurly, ex. a subscription for
      # the account/plan exists nothing is created on the application database
      # and an exception is raised. Asumes a valid user in recurly, with a
      # billing info.
      #
      # options - The Hash with the new subscription options
      #           :user - The User instance
      #           :plan_recurrence - The PlanRecurrence instance
      #           :plan_options - An Array of Option instances (optional)
      #           :shipping_info - The ShippingInfo instance (optional)
      #           :coupon - The Coupon instance (optional)
      #
      # Returns the new Subscription instance.
      # Raises Recurly::Resource::Invalid if recurly subscription fails.
      def self.create(options)
        user = options.fetch(:user)
        plan_recurrence = options.fetch(:plan_recurrence)
        merchant = plan_recurrence.plan.merchant
        plan_options = options.fetch(:options, [])
        shipping_info = options.fetch(:shipping_info, nil)
        coupon = options.fetch(:coupon, nil)

        totals_pricing = SubscriptionManager::TotalsPricing.totals({
          plan_recurrence: plan_recurrence,
          options: plan_options,
          coupon: coupon,
          user: user,
          shipping_info: shipping_info
        })

        # Create a new subscription
        subscription = Subscription.new({
          user: user,
          state: 'active',
          plan_recurrence: plan_recurrence,
          shipping_info: shipping_info,
          recurly_coupon_code: coupon ? coupon.recurly_code : '',

          # Gifting
          is_gift: !! options.fetch(:is_gift, false),
          gift_description: options.fetch(:gift_description, '') || '',
          giftee_name: options.fetch(:giftee_name, '') || '',
          giftee_email: options.fetch(:giftee_email, '') || '',
          notify_giftee_on_email: !! options.fetch(:notify_giftee_on_email, false),
          notify_giftee_on_shipment: !! options.fetch(:notify_giftee_on_shipment, false),

          # Frozen prices
          base_amount: totals_pricing[:base_amount],
          recurrent_total: totals_pricing[:recurrent_total],
          onetime_total: totals_pricing[:onetime_total],
          onetime_tax_amount: (totals_pricing[:onetime_tax] || 0),
          recurrent_tax_amount: (totals_pricing[:recurrent_tax] || 0),
          first_time_discount: (totals_pricing[:first_time_discount] || 0),
          recurrent_discount: (totals_pricing[:recurrent_discount] || 0),
          first_time_total: totals_pricing[:first_time_total],
          shipping_amount: (totals_pricing[:recurrent_shipping] || 0),
          shipping_type: merchant.shipping_type
        })

        # Create Recurly adjustments
        charges = Helpers.onetime_charges_params(totals_pricing, subscription)
        raccount = Recurly::Account.find(user.recurly_code)
        charges.each do |c|
          raccount.adjustments.create(
            description: c[:description],
            unit_amount_in_cents: Rapi::Utils::convert_to_cents(c[:amount]),
            currency: 'USD'
          )
        end

        # Get the recurly addon parameters and relate the recurrent add_ons to the subscription
        roptions = Helpers.subscription_recurly_params({
          subscription: subscription,
          totals_pricing: totals_pricing,
          plan_recurrence: plan_recurrence,
          user: user,
          coupon: coupon
        })

        # Relate the subscription to the nocharge options too
        Helpers.relate_nocharge_options_to_subscription(totals_pricing, subscription)

        rsubscription = pdate = nil
        ActiveRecord::Base.transaction do
          # The redemption is redeemed and associated with the Subscription
          if coupon
            redemption = user.find_or_create_redemption_by_coupon(coupon)
            redemption.update_attribute(:is_redeemed, true)
            subscription.redemption = redemption
          end

          rsubscription = ::Recurly::Subscription.create!(roptions)
          subscription.recurly_code = rsubscription.uuid

          # Postponment date
          pdate = SubscriptionsScheduleService.get_postponement_date(
            subscription_date: rsubscription.current_period_started_at.to_date,
            first_renewal_date: rsubscription.current_period_ends_at.to_date,
            merchant_cutoff_day: merchant.cutoff_day,
            max_delay: merchant.max_delay,
            is_shippable: plan_recurrence.plan.shippable?
          )

          subscription.current_period_started_at = rsubscription.current_period_started_at
          subscription.current_period_ends_at = pdate ? pdate : rsubscription.current_period_ends_at

          # Saving subscription
          subscription.save!

          # Try to fetch and sync the invoice for this subscription, it
          # sholud be the last invoice created for the account.
          Rapi::Invoices.sync_last_for_account(raccount)
        end

        rsubscription.postpone(pdate) if pdate

        subscription
      end

      def self.update(subscription, options)
        user = options.fetch(:user)
        plan_recurrence = options.fetch(:plan_recurrence)
        merchant = plan_recurrence.plan.merchant
        plan_options = options.fetch(:options, [])
        shipping_info = options.fetch(:shipping_info, nil)

        SubscriptionEdition.create_by_subscription(subscription)

        totals_pricing = SubscriptionManager::TotalsPricing.totals({
          plan_recurrence: plan_recurrence,
          options: plan_options,
          user: user,
          shipping_info: shipping_info
        })

        # Update subscription
        subscription.plan_recurrence = plan_recurrence
        subscription.shipping_info = shipping_info
        subscription.subscription_options = []
        subscription.base_amount = totals_pricing[:base_amount]
        subscription.recurrent_total = totals_pricing[:recurrent_total]
        subscription.recurrent_tax_amount = totals_pricing[:recurrent_tax] || 0
        subscription.recurrent_discount = totals_pricing[:recurrent_discount] || 0
        subscription.shipping_amount = totals_pricing[:recurrent_shipping] || 0
        subscription.shipping_type = merchant.shipping_type

        # Get the recurly addon parameters and relate the recurrent add_ons to the subscription
        roptions = Helpers.subscription_recurly_params({
          subscription: subscription,
          totals_pricing: totals_pricing,
          plan_recurrence: plan_recurrence,
          user: user
        }).merge(timeframe: 'renewal')
        # This attributes are no longer needed
        roptions.delete(:account)
        roptions.delete(:currency)

        # Relate the subscription to the nocharge options too
        Helpers.relate_nocharge_options_to_subscription(totals_pricing, subscription)

        # Saving subscription
        rsubscription = ::Recurly::Subscription.find(subscription.recurly_code).update_attributes(roptions)
        subscription.save!

        subscription
      end

      # Cancel a subscription on recurly and set the given subscription as
      # canceled.
      #
      # Asumes the state transition is valid, returns false if transition can't
      # be done on recurly and nothing is changed.
      #
      # subscription - The Subscription instance
      def self.cancel(subscription)
        rsubscription = Helpers.recurly_subscription(subscription)
        rsubscription.cancel

        subscription.state = 'canceled'
        subscription.canceled_at = rsubscription.canceled_at
        subscription.save(validate: false)
      end

      # Reactivates a subscription on recurly and set the given subscription as
      # active.
      #
      # Asumes the state transition is valid, returns false if transition can't
      # be done on recurly and nothing is changed.
      #
      # subscription - The Subscription instance
      def self.reactivate(subscription)
        Helpers.update_status(subscription, :reactivate)
      end

      # Terminate a subscription on recurly and set the given subscription as
      # expired.
      #
      # Asumes the state transition is valid, returns false if transition can't
      # be done on recurly and nothing is changed.
      #
      # subscription - The Subscription instance
      # refund_type - 'full' for full refund and 'none' for no refund
      def self.terminate(subscription, refund_type)
        rsubscription = Helpers.recurly_subscription(subscription)
        rsubscription.terminate(refund_type.to_sym)

        subscription.state = 'expired'
        subscription.expired_at = rsubscription.expires_at
        subscription.current_period_ends_at = rsubscription.expires_at
        subscription.save(validate: false)
      end

      # Will update current_period_started_at and current_period_ends_at which describe
      # the last billing period of the subscription
      #
      # subscription - The ActiveRecord subscription instance
      def self.update_current_period(subscription)
        rsubscription = Helpers.recurly_subscription(subscription)

        subscription.current_period_started_at = rsubscription.current_period_started_at
        subscription.current_period_ends_at = [rsubscription.current_period_ends_at, rsubscription.expires_at].select {|d| d }.min
        subscription.save(validate: false)
      end

      module Helpers
        module_function

        def recurly_subscription(subscription)
          ::Recurly::Subscription.find(subscription.recurly_code)
        end

        def subscription_recurly_params(options)
          totals_pricing = options.fetch(:totals_pricing)
          subscription = options.fetch(:subscription)
          plan_recurrence = options.fetch(:plan_recurrence)
          user = options.fetch(:user)
          coupon = options.fetch(:coupon, nil)

          addons = addons_recurly_params(totals_pricing, subscription, plan_recurrence)
          params = {
            plan_code: plan_recurrence.recurly_plan_code,
            currency: 'USD',
            account: { account_code: user.recurly_code },
          }
          params[:add_ons] = addons if addons.any?
          params[:coupon_code] = coupon.recurly_code if coupon

          params
        end

        def addons_recurly_params(totals_pricing, subscription, plan_recurrence)
          # Plan Options: Plan addons and adjustments
          addons = []

          totals_pricing[:recurrent_options].each do |option|
            option_id = option.fetch(:option_id)
            amount = option.fetch(:amount)
            quantity = option.fetch(:quantity)

            # Creating association
            subscription.subscription_options.new(option_id: option_id, unit_amount: amount, quantity: quantity)

            next if amount.nil? || amount.zero?

            option_recurly_code = plan_recurrence.option_recurly_codes.find_by_option_id(option_id).recurly_code
            addons << {
              add_on_code: option_recurly_code,
              unit_amount: amount,
              quantity: quantity
            }
          end

          # Shipping addon
          if totals_pricing[:recurrent_shipping]
            addons << {
              add_on_code: 'shipping',
              unit_amount_in_cents: Rapi::Utils::convert_to_cents(totals_pricing[:recurrent_shipping])
            }
          end

          # Taxes addon
          if totals_pricing[:recurrent_tax]
            addons << {
              add_on_code: 'tax',
              unit_amount_in_cents: Rapi::Utils::convert_to_cents(totals_pricing[:recurrent_tax])
            }
          end

          addons
        end

        def onetime_charges_params(totals_pricing, subscription)
          # Adjustments
          charges = []

          totals_pricing[:onetime_options].each do |option|
            option_id = option.fetch(:option_id)
            amount = option.fetch(:amount)

            subscription.subscription_options.new(option_id: option_id, unit_amount: amount, quantity: 1)

            next if amount.nil? || amount.zero?

            description = Option.find(option_id).invoice_description
            charges << { description: description, amount: amount }
          end

          # Taxes adjustment
          if totals_pricing[:onetime_tax]
            charges << { description: 'Taxes for one-time services', amount: totals_pricing[:onetime_tax] }
          end

          charges
        end

        def relate_nocharge_options_to_subscription(totals_pricing, subscription)
          totals_pricing[:nocharge_options].each do |option|
            option_id = option.fetch(:option_id)
            subscription.subscription_options.new(option_id: option_id)
          end
        end

        def update_status(subscription, action)
          recurly_subscription(subscription).send(action).tap do |r|
            if r
              subscription.state = {
                cancel: 'canceled',
                reactivate: 'active',
              }[action]
              subscription.save(validate: false)
            end
          end
        end
      end

    end
  end
end
