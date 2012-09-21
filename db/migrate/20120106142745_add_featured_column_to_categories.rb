class AddFeaturedColumnToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :is_featured, :boolean
  end
end
