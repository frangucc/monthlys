class AddSubscriptionsRecurlyCouponCode < ActiveRecord::Migration
  def change
    add_column(:subscriptions, :recurly_coupon_code, :string, null: true, default: nil)
  end
end
