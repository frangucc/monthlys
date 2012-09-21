class AddCityAndStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_city, :string
    add_column :users, :user_state, :string
  end
end
