class RenameMerchantImageColumn < ActiveRecord::Migration
  def change
    rename_column :merchants, :image_file_name, :merchant_image_file_name
    rename_column :merchants, :image_content_type, :merchant_image_content_type
    rename_column :merchants, :image_file_size, :merchant_image_file_size
    rename_column :merchants, :image_updated_at, :merchant_image_updated_at
  end
end
