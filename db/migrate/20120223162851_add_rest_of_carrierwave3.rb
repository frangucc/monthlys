class AddRestOfCarrierwave3 < ActiveRecord::Migration
  def up
    rename_column :merchants, :merchant_image_file_name, :merchant_image
    remove_column :merchants, :merchant_image_file_size
    remove_column :merchants, :merchant_image_content_type
    remove_column :merchants, :merchant_image_updated_at

    rename_column :merchants, :logo_file_name, :logo
    remove_column :merchants, :logo_file_size
    remove_column :merchants, :logo_content_type
    remove_column :merchants, :logo_updated_at

    rename_column :offers, :image_file_name, :image
    remove_column :offers, :image_file_size
    remove_column :offers, :image_content_type
    remove_column :offers, :image_updated_at

    rename_column :offers, :thumbnail_file_name, :thumbnail
    remove_column :offers, :thumbnail_file_size
    remove_column :offers, :thumbnail_content_type
    remove_column :offers, :thumbnail_updated_at

    rename_column :offers, :icon_file_name, :icon
    remove_column :offers, :icon_file_size
    remove_column :offers, :icon_content_type
    remove_column :offers, :icon_updated_at

    rename_column :plans, :plan_image_file_name, :plan_image
    remove_column :plans, :plan_image_file_size
    remove_column :plans, :plan_image_content_type
    remove_column :plans, :plan_image_updated_at
  end

  def down
  end
end
