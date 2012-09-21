class AddCouponsSingleUseDefault < ActiveRecord::Migration
  def change
    change_column(:coupons, :single_use, :boolean, null: false, default: true)
  end
end
