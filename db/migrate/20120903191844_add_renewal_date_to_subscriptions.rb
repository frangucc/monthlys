class AddRenewalDateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscription_editions, :next_renewal_date, :date, default: nil
  end
end
