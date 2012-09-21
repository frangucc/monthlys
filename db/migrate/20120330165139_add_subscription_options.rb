class AddSubscriptionOptions < ActiveRecord::Migration
  def change
    create_table :subscription_options do |t|
      t.integer :subscription_id
      t.integer :option_id
      t.decimal :unit_amount, precision: 10, scale: 2, null: true, default: nil
    end
  end
end
