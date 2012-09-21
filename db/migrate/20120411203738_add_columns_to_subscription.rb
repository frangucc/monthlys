class AddColumnsToSubscription < ActiveRecord::Migration
  def change
  	add_column :subscriptions, :shipping_amount, :float
  	add_column :subscriptions, :shipping_type, :string
  end
end
