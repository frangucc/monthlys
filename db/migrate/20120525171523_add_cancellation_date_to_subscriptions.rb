class AddCancellationDateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :deactivated_at, :datetime
  end
end
