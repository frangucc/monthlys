class AddLastPaymentDateAndAmountToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :last_payment_date, :date
    add_column :subscriptions, :last_payment_amount, :decimal, precision: 10, scale: 2
  end
end
