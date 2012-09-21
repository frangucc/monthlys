class RegisterCouponsConstraint

  def matches?(request)
    Monthly::Application.config.app_config.register_coupons.keys.include?(request.params[:coupon_name].to_sym)
  end
end
