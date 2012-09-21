class AddRestOfCarrierwave2 < ActiveRecord::Migration
  def up
    rename_column :cities, :city_image_file_name, :image
    remove_column :cities, :city_image_file_size
    remove_column :cities, :city_image_content_type
    remove_column :cities, :city_image_updated_at
  end

  def down
  end
end
