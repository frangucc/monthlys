class AddExpiredAtAndCanceledAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :expired_at, :datetime
    rename_column :subscriptions, :deactivated_at, :canceled_at
  end
end
