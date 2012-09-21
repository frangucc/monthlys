class AddIsPastDueToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :is_past_due, :boolean, default: false, null: false
  end
end
