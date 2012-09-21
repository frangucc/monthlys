class AddPeriodFieldsToSubscriptions < ActiveRecord::Migration
  def change
    add_column(:subscriptions, :last_successful_payment, :string, null: false, default: '')
    add_column(:subscriptions, :last_successful_payment_date, :date)
    add_column(:subscriptions, :period_start_date, :date)
  end
end
