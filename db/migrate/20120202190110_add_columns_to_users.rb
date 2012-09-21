class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :roles, :integer
    add_column :merchants, :user_id, :integer
  end
end
