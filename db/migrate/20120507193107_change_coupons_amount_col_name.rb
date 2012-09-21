class ChangeCouponsAmountColName < ActiveRecord::Migration
  def up
    rename_column(:coupons, :discount_in_cents, :discount_in_usd)
    change_column(:coupons, :discount_in_usd, :decimal, scale:  2, precision: 10, null: true, default: nil)
  end

  def down
    rename_column(:coupons, :discount_in_usd, :discount_in_cents)
  end
end
