class RenameSubscriptionsRenewalDateField < ActiveRecord::Migration
  def up
    change_column :subscriptions, :renewal_date, :datetime
    change_column :subscriptions, :current_period_started_at, :datetime
    change_column :subscriptions, :last_payment_date, :datetime
    rename_column :subscriptions, :renewal_date, :current_period_ends_at
  end

  def down
    rename_column :subscriptions, :current_period_ends_at, :renewal_date
    change_column :subscriptions, :last_payment_date, :date
    change_column :subscriptions, :current_period_started_at, :date
    change_column :subscriptions, :renewal_date, :date
  end
end
