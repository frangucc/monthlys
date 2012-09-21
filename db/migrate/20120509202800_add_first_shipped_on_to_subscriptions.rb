class AddFirstShippedOnToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :first_shipping_date, :date
  end
end
