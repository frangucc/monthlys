class AddFeaturedCouponToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :featured_coupon_id, :integer
  end
end
