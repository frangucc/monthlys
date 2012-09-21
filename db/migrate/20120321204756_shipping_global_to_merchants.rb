class ShippingGlobalToMerchants < ActiveRecord::Migration
  def up
    remove_column :plans, :shipping_type
    remove_column :plans, :shipping_rate
    add_column :merchants, :shipping_type, :string, limit: 10
    add_column :merchants, :shipping_rate, :decimal, precision: 7, scale: 2
  end

  def down
    add_column :plans, :shipping_type, :string, limit: 10
    add_column :plans, :shipping_rate, :decimal, precision: 7, scale: 2
    remove_column :merchants, :shipping_type
    remove_column :merchants, :shipping_rate
  end
end
