class ChangeColumnCouponsDiscountPercentToInt < ActiveRecord::Migration
  def up
    change_column(:coupons, :discount_percent, :integer, null: true, default: nil)
  end

  def down
    change_column(:coupons, :discount_percent, :decimal)
  end
end
