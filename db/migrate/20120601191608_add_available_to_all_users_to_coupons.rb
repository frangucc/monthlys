class AddAvailableToAllUsersToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :available_to_all_users, :boolean, null: false, default: false
  end
end
