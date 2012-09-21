class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.string :email
      t.integer :friend_of_id
      t.integer :user_id

      t.timestamps
    end
  end
end
