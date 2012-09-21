class AddCurrentPeriodStartedAtFieldOnSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :current_period_started_at, :date
  end
end
