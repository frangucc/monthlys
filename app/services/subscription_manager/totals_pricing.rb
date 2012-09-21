module SubscriptionManager

  # Public: Methods for calculating a subscription pricing totals.
  #
  # This module takes care of the data at the ORM layer level,
  # extracting the needed values and delegating calulations to
  # SubscriptionManager::Calculator methods.
  #
  # All methods are module methods and should be called on the
  # TotalsPricing module.
  module TotalsPricing

    module_function

    # Public: This methods extracts the needed arguments for
    #   SubscriptionManager::Calculator.calculate_totals from the ORM
    #   objects it recieves as arguments.
    #
    # resources - The Hash options:
    #             :plan_recurrence - The PlanRecurrence of the subscription.
    #             :options - The Options of the subscription.
    #             :user - The subscriber User, used for extracting the user
    #                     state for shipping/taxes information (optional).
    #             :shipping_info - The ShippingInfo used for extracting
    #                              the state for shpping/taxes
    #                              information (optional).
    #             :coupon - The Coupon used in the subscription (optional).
    #
    # Returns a Hash with all the pricing totals, see
    #   SubscriptionManager::Calculator.calculate_totals return section.
    def totals(resources)
      plan_recurrence = resources.fetch(:plan_recurrence)
      options = resources.fetch(:options)
      user = resources.fetch(:user, nil)
      shipping_info = resources.fetch(:shipping_info, nil)
      coupon = resources.fetch(:coupon, nil)

      merchant = plan_recurrence.plan.merchant
      state = obtain_state(user, shipping_info)

      # Shipping
      shipping_type = merchant.shipping_type.to_sym
      shipping_amount = 0
      if shipping_type == :flat_rate && merchant.shipping_rate
        shipping_amount = merchant.shipping_rate
      elsif shipping_type == :state_dependant && (percentage = merchant.shipping_prices.find_by_state_id(state.id).try(:percentage))
        shipping_amount = percentage
      end

      # Taxes
      tax_factor = (merchant.tax_rates.find_by_state_id(state.id).try(:percentage) || 0) / 100
      taxation_policy = merchant.taxation_policy.to_sym

      pricing_data = {
        base_amount: plan_recurrence.amount,
        services_per_billing_cycle: plan_recurrence.services_per_billing_cycle,
        options: options.map { |o| { id: o.id, amount: o.amount, type: o.option_type } },
        taxation: { taxation_policy: taxation_policy, tax_factor: tax_factor },
        shipping: { shipping_type: shipping_type, amount: shipping_amount }
      }

      # Discounts
      if coupon
        discount_type = coupon.discount_type.to_sym
        discount_period = coupon.single_use? ? :single_use : :recurrent
        amount = discount_type == :dollars ? coupon.discount_in_usd : coupon.discount_percent

        pricing_data[:coupon] = { discount_period: discount_period, discount_type: discount_type, amount: amount }
      end

      SubscriptionManager::Calculator.calculate_totals(pricing_data)
    end

    # Public: Get the State from the given User if available or else
    #   from the given ShippingInfo. If none found defaults to Illinois.
    #
    # user - The User instance.
    # shipping_info - The ShippingInfo instance.
    #
    # Returns the State for the given user or shipping info. Defaults
    #   to illinois if not found given.
    def obtain_state(user, shipping_info)
      state_id = (shipping_info && shipping_info.zipcode && shipping_info.zipcode.state.id) ||
        (user && user.zipcode && user.zipcode.state.id)

      (state_id && State.find(state_id)) || State.find_by_code('IL') # FIXME: Magic string
    end
  end
end
