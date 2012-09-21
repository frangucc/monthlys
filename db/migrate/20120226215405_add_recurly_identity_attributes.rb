class AddRecurlyIdentityAttributes < ActiveRecord::Migration
  def change
    add_column :users, :recurly_code, :string, :null => false, :default => ""
    add_index :users, :recurly_code
    add_column :subscriptions, :recurly_code, :string, :null => false, :default => ""
    add_index :subscriptions, :recurly_code
    rename_column :plans, :recurly_reference_name, :recurly_code
  end
end
