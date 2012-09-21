class AddQuantityFieldToSubscriptionOptions < ActiveRecord::Migration
  def change
    add_column :subscription_options, :quantity, :integer, null: false, default: 1
  end
end
