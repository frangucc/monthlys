class CreateAdminActivitiesTable < ActiveRecord::Migration
  def up
    create_table :admin_activities do |t|
      t.string :verb
      t.integer :admin_user_id
      t.integer :object_id
      t.string :object_type
      t.text :previous_attributes
      t.text :new_attributes
      t.timestamps
    end
  end

  def down
    drop_table :admin_activities
  end
end
