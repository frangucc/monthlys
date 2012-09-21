class AddIconsToCategories < ActiveRecord::Migration
  def change
    # Icons
    add_column :categories, :icon_file_name, :string
    add_column :categories, :icon_content_type, :string
    add_column :categories, :icon_file_size, :string
    add_column :categories, :icon_updated_at, :string
  end
end
