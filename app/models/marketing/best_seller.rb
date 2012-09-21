class Marketing::BestSeller < ActiveRecord::Base

  belongs_to :plan
  belongs_to :coupon
  has_and_belongs_to_many :newsletters, class_name: 'Marketing::Newsletter'

  validate :coupon_is_available_for_plan
  validates :plan, presence: true
  validates :newsletters, presence: true

  def to_s
    string = plan.name
    string << " - #{coupon.coupon_code}" if coupon
    string
  end

  def coupon_is_available_for_plan
    if coupon && plan && !(coupon.available_to_all_plans? || plan.coupons.include?(coupon))
      errors.add(:coupon, ' is not available for the selected plan')
    end
  end

  def featured_price
    featured_price = if coupon
      totals_pricing = SubscriptionManager::TotalsPricing.totals({
        plan_recurrence: plan.cheapest_plan_recurrence,
        options: [],
        coupon: coupon
      })
      totals_pricing[:first_time_without_extras] # cheapest_plan_recurrence - coupon
    else
      plan.cheapest_plan_recurrence.pretty_amount # cheapest_plan_recurrence
    end

    sprintf('%.02f', featured_price)
  end
end
