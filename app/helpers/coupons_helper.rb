module CouponsHelper

  def pretty_explanation(coupon)
    description = coupon.pretty_discount.dup

    if coupon.applies_to_all_plans?
      description << " on all Monthlys plans."
    else
      description << " on #{coupon.plans.map {|p| link_to(p.name, ms_path(plan_path(p))) }.to_sentence}"
    end

    description.html_safe
  end
end
