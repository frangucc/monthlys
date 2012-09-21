class AddRestOfCarrierwave < ActiveRecord::Migration
  def change
    rename_column :categories, :image_file_name, :image
    remove_column :categories, :image_file_size
    remove_column :categories, :image_content_type
    remove_column :categories, :image_updated_at

    rename_column :categories, :thumbnail_file_name, :thumbnail
    remove_column :categories, :thumbnail_file_size
    remove_column :categories, :thumbnail_content_type
    remove_column :categories, :thumbnail_updated_at

    rename_column :categories, :icon_file_name, :icon
    remove_column :categories, :icon_file_size
    remove_column :categories, :icon_content_type
    remove_column :categories, :icon_updated_at
  end

end
