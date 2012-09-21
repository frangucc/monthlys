class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :name
      t.string :general_info
      t.string :shipping_info
      t.string :details
      t.string :video_url

      # Relations
      t.integer :merchant_id

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
      # Icon
      t.string :icon_file_name
      t.string :icon_content_type
      t.integer :icon_file_size
      t.datetime :icon_updated_at

      t.timestamps
    end
  end
end
