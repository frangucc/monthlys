class CreateCouponsPlansTable < ActiveRecord::Migration
  def change
    create_table :coupons_plans do |t|
      t.integer :plan_id
      t.integer :coupon_id
    end
  end
end
