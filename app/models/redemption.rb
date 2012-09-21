class Redemption < ActiveRecord::Base
  belongs_to :coupon
  belongs_to :user
  has_one :subscription

  scope :automatic_redemptions, where(customer_service: false)
  scope :customer_service, where(customer_service: true)

  def active?
    !redeemed? && !expired?
  end

  def expired?
    !redeemed? && coupon.expired?
  end

  def redeemed?
    is_redeemed?
  end
end
