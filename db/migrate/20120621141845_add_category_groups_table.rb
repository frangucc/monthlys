class AddCategoryGroupsTable < ActiveRecord::Migration
  def up
    create_table :category_groups do |t|
      t.string :name
      t.string :image
      t.string :icon

      t.timestamps
    end

    rename_column :categories, :parent_id, :category_group_id
  end

  def down
    drop_table :category_groups
  end
end
