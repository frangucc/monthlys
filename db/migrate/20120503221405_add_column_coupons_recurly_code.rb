class AddColumnCouponsRecurlyCode < ActiveRecord::Migration
  def change
    add_column(:coupons, :recurly_code, :string, null: true, default: nil)
  end
end
