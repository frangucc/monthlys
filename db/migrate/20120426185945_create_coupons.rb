class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :coupon_code
      t.string :name
      t.string :marketing_description
      t.string :invoice_description
      t.date :redeem_by_date
      t.boolean :single_use
      t.integer :applies_for_months
      t.integer :max_redemptions
      t.boolean :applies_to_all_plans
      t.string :discount_type
      t.decimal :discount_percent
      t.decimal :discount_in_cents
      t.boolean :is_active
      t.string :image
      t.timestamps
    end
  end
end
