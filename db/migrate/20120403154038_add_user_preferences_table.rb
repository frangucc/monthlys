class AddUserPreferencesTable < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.integer :category_id
      t.integer :user_id
      t.integer :zipcode_id
      t.string :status
      t.integer :plan_id
      t.timestamps
    end
  end
end
