class RemoveFieldsFromUsers < ActiveRecord::Migration
  def up
    add_column :users, :zipcode_id, :integer
    remove_column :users, :user_state
    remove_column :users, :user_city
    remove_column :users, :city_id
  end

  def down
  end
end
