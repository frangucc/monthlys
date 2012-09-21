class AddIsTestFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_test, :boolean, null: false, default: false
  end
end
