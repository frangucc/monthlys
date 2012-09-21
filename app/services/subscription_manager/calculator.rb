module SubscriptionManager

  # Public: Methods for calculating a subscription pricing totals.
  #
  # This module takes care of the needed mathematical calculations to
  # get the pricing totals and subtotals from the set of values passed
  # as arguments.
  #
  # pricing_data - A Hash with options:
  #                :base_amount - A base BigDecimal amount, usually
  #                               from a plan recurrence.
  #                :services_per_billing_cycle - The Integer amount of
  #                                             services per billing.
  #                :options - A Hash with the options data:
  #                           :id - The Option id
  #                           :amount - The BigDecimal option amount.
  #                           :type - The option type (:onetime,
  #                                   :per_service, :per_billing or :nocharge)
  #                :taxation - A Hash with the taxation options:
  #                            :taxation_policy - The tax policy to
  #                             apply (:tax_plans or :tax_plans_plus_shippings)
  #                :shipping - A Hash with the shipping options
  #                            :shipping_type
  #                            :amount
  #                :coupon - A Hash with the coupon options (optional):
  #                          :discount_period
  #                          :discount_type
  #                          :amount
  #
  module Calculator

    module_function

    def calculate_totals(pricing_data)
      base_amount = pricing_data.fetch(:base_amount)
      services_per_billing_cycle = pricing_data.fetch(:services_per_billing_cycle)
      options = pricing_data.fetch(:options)
      taxation = pricing_data.fetch(:taxation)
      shipping = pricing_data.fetch(:shipping)
      coupon = pricing_data.fetch(:coupon, nil)

      # Recurrent
      recurrent_options_total, recurrent_options = get_recurrent_options_total(options, services_per_billing_cycle)
      recurrent_without_extras = base_amount + recurrent_options_total

      shipping_total = get_shipping_total(shipping, recurrent_without_extras, services_per_billing_cycle)
      recurrent_subtotal_with_shipping = recurrent_without_extras + (shipping_total || 0)

      tax_total = get_taxation_total(taxation, recurrent_without_extras, recurrent_subtotal_with_shipping)
      tax_total = nil if tax_total && tax_total.zero?
      recurrent_total = recurrent_subtotal_with_shipping + (tax_total || 0)

      recurrent_discount = nil
      if coupon && coupon[:discount_period] == :recurrent
        recurrent_discount = get_recurrent_discount(coupon, recurrent_total)
        recurrent_total -= recurrent_discount
      end

      # No charge
      nocharge_options = get_nocharge_options(options)

      # Onetime
      onetime_total, onetime_options = get_onetime_options_total(options)
      onetime_tax_total = nil
      if onetime_total > 0 && get_onetime_taxation_total(taxation, onetime_total) > 0
        onetime_tax_total = get_onetime_taxation_total(taxation, onetime_total)
        onetime_total = onetime_total + onetime_tax_total
      end

      # First-time
      first_time_total = recurrent_total + onetime_total
      first_time_without_extras = recurrent_without_extras # This is the first time total without taxes and shipping
      first_time_discount = nil
      if coupon && coupon[:discount_period] == :single_use
        first_time_discount = get_first_time_discount(coupon, {
          recurrent_total: recurrent_total,
          base_amount: base_amount,
          options: options,
          recurrent_tax: tax_total,
          services_per_billing_cycle: services_per_billing_cycle,
          recurrent_shipping: shipping_total
        })
        first_time_total -= first_time_discount
        first_time_without_extras -= get_first_time_discount(coupon, {
          recurrent_total: recurrent_without_extras,
          base_amount: base_amount,
          options: options,
          services_per_billing_cycle: services_per_billing_cycle
        })
      end

      {
        # Totals
        recurrent_total: recurrent_total,
        onetime_total: onetime_total,
        first_time_total: first_time_total,
        first_time_without_extras: first_time_without_extras,

        # Recurrent
        base_amount: base_amount,
        recurrent_without_extras: recurrent_without_extras,
        recurrent_options: recurrent_options,

        # Extras
        recurrent_shipping: shipping_total,
        recurrent_tax: tax_total,
        nocharge_options: nocharge_options,

        # Onetime
        onetime_tax: onetime_tax_total,
        onetime_options: onetime_options,

        # Discounts
        recurrent_discount: recurrent_discount,
        first_time_discount: first_time_discount
      }
    end

    # Recurrent amounts
    def get_recurrent_options_total(options_data, services_per_billing_cycle)
      options_pricing_data = []
      options_total = 0

      options_data.each do |option|
        type = option.fetch(:type)
        amount = option.fetch(:amount).round(2)
        id = option.fetch(:id)
        quantity = ((type == :per_service)? services_per_billing_cycle : 1)

        next unless [:per_service, :per_billing].include?(type)

        pricing_data = {
          option_id: id,
          amount: amount,
          quantity: quantity,
          amount_per_billing_cycle: (quantity * amount)
        }

        options_pricing_data << pricing_data

        options_total += pricing_data[:amount] * pricing_data[:quantity]
      end

      [options_total, options_pricing_data]
    end

    def get_shipping_total(shipping_data, subtotal, services_per_billing_cycle)
      shipping_type = shipping_data.fetch(:shipping_type)
      amount = shipping_data.fetch(:amount)

      case shipping_type
      when :flat_rate then (amount * services_per_billing_cycle).round(2)
      when :state_dependant then (amount * subtotal / 100).round(2)
      else nil
      end
    end

    def get_taxation_total(taxation_data, subtotal_without_shipping, subtotal_with_shipping)
      taxation_policy = taxation_data.fetch(:taxation_policy)
      tax_factor = taxation_data.fetch(:tax_factor)

      case taxation_policy
      when :tax_plans_plus_shippings then (subtotal_with_shipping * tax_factor).round(2)
      when :tax_plans then (subtotal_without_shipping * tax_factor).round(2)
      else nil
      end
    end

    def get_recurrent_discount(coupon, recurrent_total)
      nil # TODO: Implement
    end

    # No charge
    def get_nocharge_options(options)
      nocharge_options = []
      options.each do |option|
        option_id = option.fetch(:id)
        type = option.fetch(:type)

        nocharge_options << { option_id: option_id } if type == :nocharge
      end

      nocharge_options
    end

    # Onetime amounts
    def get_onetime_options_total(options)
      options_pricing_data = []
      options_total = 0

      options.each do |option|
        option_id = option.fetch(:id)
        type = option.fetch(:type)
        amount = option.fetch(:amount).round(2)

        next unless type == :onetime

        options_pricing_data << {
          option_id: option_id,
          amount: amount
        }

        options_total += amount
      end

      [options_total, options_pricing_data]
    end

    def get_onetime_taxation_total(taxation_data, onetime_subtotal)
      taxation_policy = taxation_data.fetch(:taxation_policy)
      tax_factor = taxation_data.fetch(:tax_factor)

      [:tax_plans_plus_shippings, :tax_plans].include?(taxation_policy) ? (onetime_subtotal * tax_factor).round(2) : 0
    end

    # First time amounts
    def get_first_time_discount(coupon, options)
      discount_type = coupon.fetch(:discount_type)
      discount_amount = coupon.fetch(:amount)

      base_amount = options.fetch(:base_amount)
      recurrent_options = options.fetch(:options).select {|o| [:per_service, :per_billing].include?(o[:type]) }
      services_per_billing_cycle = options.fetch(:services_per_billing_cycle)
      recurrent_total = options.fetch(:recurrent_total)
      recurrent_shipping = options.fetch(:recurrent_shipping, nil)
      recurrent_tax = options.fetch(:recurrent_tax, nil)

      case discount_type
      when :percent
        percent_discount_for = proc {|base| (base.round(2) * discount_amount / 100).round(2) }

        discount = percent_discount_for.call(base_amount)

        discount += recurrent_options.inject(0) do |sum, op|
          amount = percent_discount_for.call(op[:amount])
          amount *= services_per_billing_cycle if op[:type] == :per_service

          sum + amount
        end

        discount += percent_discount_for.call(recurrent_shipping) if recurrent_shipping

        discount += percent_discount_for.call(recurrent_tax) if recurrent_tax

        discount
      when :dollars
        [discount_amount, recurrent_total].min
      else
        nil
      end
    end
  end
end
