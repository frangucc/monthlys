class AddSubscriptionFreezedPricesFields < ActiveRecord::Migration
  def up
    change_table :subscriptions do |t|
      # Totals
      t.decimal :recurrent_total, precision: 10, scale: 2, null: false, default: 0
      t.decimal :onetime_total, precision: 10, scale: 2, null: false, default: 0
      t.decimal :first_time_total, precision: 10, scale: 2, null: false, default: 0

      # Taxes
      t.decimal :onetime_tax_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :recurrent_tax_amount, precision: 10, scale: 2, null: false, default: 0

      # Discounts
      t.decimal :first_time_discount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :recurrent_discount, precision: 10, scale: 2, null: false, default: 0
    end
  end

  def down
    remove_column :subscriptions, :recurrent_total
    remove_column :subscriptions, :first_time_total
    remove_column :subscriptions, :onetime_total
    remove_column :subscriptions, :onetime_tax_amount
    remove_column :subscriptions, :recurrent_tax_amount
    remove_column :subscriptions, :first_time_discount
    remove_column :subscriptions, :recurrent_discount
  end
end
