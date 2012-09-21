class AddCityIdToUsers < ActiveRecord::Migration
  def up
  	add_column :users, :city_id, :integer
    # Save all users again to store their city_id to get their city and state.
  	# User.reset_column_information
  	# User.all.each(&:save)
  end

  def down
  	remove_column :users, :city_id
  end
end
