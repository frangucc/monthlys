class AddUsersAddressColumns < ActiveRecord::Migration
  def change
    add_column(:users, :address, :string, null: false, default: '')
    add_column(:users, :city, :string, null: false, default: '')
    add_column(:users, :state_id, :string, null: false, default: '')
  end
end
