class AddFieldsToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :next_shipping_date, :date
    add_column :subscriptions, :shipping_status, :string
  end
end
