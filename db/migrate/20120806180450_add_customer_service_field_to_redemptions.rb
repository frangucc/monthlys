class AddCustomerServiceFieldToRedemptions < ActiveRecord::Migration
  def change
    add_column :redemptions, :customer_service, :boolean, default: false, null: false
  end
end
