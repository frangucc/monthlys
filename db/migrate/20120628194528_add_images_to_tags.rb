class AddImagesToTags < ActiveRecord::Migration
  def change
    add_column :tags, :header_image, :string, null: false, default: ''
  end
end
