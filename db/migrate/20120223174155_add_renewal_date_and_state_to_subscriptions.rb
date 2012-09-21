class AddRenewalDateAndStateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :renewal_date, :date
    add_column :subscriptions, :status, :integer
  end
end
