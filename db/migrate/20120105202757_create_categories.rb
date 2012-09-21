class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :subscription_id

      # Image
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      # Thumb
      t.string :thumbnail_file_name
      t.string :thumbnail_content_type
      t.integer :thumbnail_file_size
      t.datetime :thumbnail_updated_at

      t.timestamps
    end
  end
end
