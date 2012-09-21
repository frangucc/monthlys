module SubscriptionsScheduleService

  module_function

  # Returns the postponement date if the subscription needs
  # postponement or nil otherwise.
  def get_postponement_date(options)
    subscription_date = options.fetch(:subscription_date)
    first_renewal_date = options.fetch(:first_renewal_date)
    merchant_cutoff_day = options.fetch(:merchant_cutoff_day)
    max_delay = options.fetch(:max_delay)
    is_shippable = options.fetch(:is_shippable)

    return nil unless is_shippable

    first_mcd = get_first_merchant_cutoff_date(subscription_date, merchant_cutoff_day)
    postponement_end = first_mcd + max_delay

    (first_mcd..postponement_end).include_with_range?(first_renewal_date) ? postponement_end + 1.day : nil
  end

  # Returns the first merchant cutoff day for the given subscription
  # date and merchant cutoff day.
  def get_first_merchant_cutoff_date(subscription_date, merchant_cutoff_day)
    next_month = subscription_date + 1.month
    Date.new(next_month.year, next_month.month, merchant_cutoff_day)
  end

  def next_cutoff_date_after(date, merchant)
    next_cutoff = Date.civil(date.year, date.month, merchant.cutoff_day)
    next_cutoff += 1.month if date.day >= merchant.cutoff_day

    next_cutoff
  end

  def get_orders_for(date)
    Subscription.where('
      (
        subscriptions.is_past_due = ? AND
        subscriptions.created_at::date <= (TIMESTAMP ?)::date AND
        subscriptions.current_period_started_at::date > (TIMESTAMP ?)::date
      )
      OR
      (
        subscriptions.is_past_due = ? AND
        subscriptions.created_at::date <= (TIMESTAMP ?)::date AND
        subscriptions.current_period_ends_at::date > (TIMESTAMP ?)::date
      )
    ', true, date, date, false, date, date)
  end

  def active_shipping_on?(subscription, date)
    if subscription.is_past_due?
      subscription.created_at <= date && date < subscription.current_period_starts_at
    else
      subscription.created_at <= date && date < subscription.current_period_ends_at
    end
  end
end
