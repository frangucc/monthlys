class AddStateToSubscriptions < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :status
    add_column :subscriptions, :state, :string, :null => false, :default => "inactive"
  end
end
