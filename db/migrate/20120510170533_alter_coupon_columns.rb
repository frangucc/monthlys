class AlterCouponColumns < ActiveRecord::Migration
  def change
    change_column :redemptions, :is_redeemed, :boolean, default: false, null: false
  end
end
