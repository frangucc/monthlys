class CouponsController < ApplicationController

  load_and_authorize_resource

  def index
    @active_coupons = current_user.active_redemptions.map(&:coupon)
    @redeemed_coupons = current_user.redeemed_redemptions.map(&:coupon)
    @expired_coupons = current_user.expired_redemptions.map(&:coupon)

    @show_invite_friends_coupon = !merchant_storefront? && current_user.redemptions.includes(:coupon).where(coupons: { coupon_code: Monthly::Application::INVITING_COUPON_CODE }).empty?
  end
end
