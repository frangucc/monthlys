class RenameSubscriptionsToPlans < ActiveRecord::Migration
  def change
    rename_table :subscriptions, :plans

    rename_column :categories, :subscription_id, :plan_id
    rename_column :packages, :subscription_id, :plan_id

    remove_index :categories_subscriptions, :subscription_id
    rename_table :categories_subscriptions, :categories_plans
    rename_column :categories_plans, :subscription_id, :plan_id
    add_index :categories_plans, :plan_id
  end
end
