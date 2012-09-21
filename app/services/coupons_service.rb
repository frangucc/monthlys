module Monthly
  module CouponsService
    module_function

    def coupons_by_user_scope(user)
      Coupon.unscoped
    end

    def coupon_available_for_user?(coupon_code, user)
      false
    end
  end
end
