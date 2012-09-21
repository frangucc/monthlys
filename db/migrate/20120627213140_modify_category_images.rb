class ModifyCategoryImages < ActiveRecord::Migration
  def change
    add_column :categories, :header_image, :string, null: false, default: ''
  end
end
