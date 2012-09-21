class AddSubscriptionBaseAmount < ActiveRecord::Migration
  def change
    add_column(:subscriptions, :base_amount, :decimal, precision: 10, scale: 2, null: false, default: 0)
  end
end
