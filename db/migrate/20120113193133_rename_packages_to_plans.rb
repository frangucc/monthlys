class RenamePackagesToPlans < ActiveRecord::Migration
  def change
    rename_table :packages, :plans
    rename_column :subscriptions, :package_id, :plan_id
  end
end
