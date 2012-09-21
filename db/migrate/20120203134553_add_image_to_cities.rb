class AddImageToCities < ActiveRecord::Migration
  def change
    # Images
    add_column :cities, :city_image_file_name, :string
    add_column :cities, :city_image_content_type, :string
    add_column :cities, :city_image_file_size, :string
    add_column :cities, :city_image_updated_at, :string
  end
end
