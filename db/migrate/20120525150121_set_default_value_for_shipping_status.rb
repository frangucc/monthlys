class SetDefaultValueForShippingStatus < ActiveRecord::Migration
  def change
    change_column :subscriptions, :shipping_status, :string, null: false, default: "active"
  end
end
