class SubscriptionEdition < ActiveRecord::Base

  belongs_to :subscription

  serialize :attributes_data, Hash
  serialize :pricing_data, Hash

  class << self
    def create_by_subscription(subscription)
      se = self.new(subscription: subscription)

      plan_recurrence = subscription.plan_recurrence
      options = subscription.options
      coupon = subscription.coupon
      shipping_info = subscription.shipping_info

      se.attributes_data = {
        plan_recurrence: "#{plan_recurrence.shipping_desc} for #{plan_recurrence.pretty_explanation}",
        options: options.map {|o| "$ #{o.amount} - #{o.option_group.description}: #{o.title}"},
        coupon: coupon.try(:name),
        shipping_info: shipping_info.try(:pretty_address),
        shipping_type: subscription.shipping_type
      }

      se.pricing_data = {
        base_amount: subscription.base_amount,
        shipping_amount: subscription.shipping_amount,
        recurrent_tax_amount: subscription.recurrent_tax_amount,
        recurrent_discount: subscription.recurrent_discount,
        recurrent_total: subscription.recurrent_total
      }

      se.next_renewal_date = subscription.renewal_date

      se.save
    end
  end
end
