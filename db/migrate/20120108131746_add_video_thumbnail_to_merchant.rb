class AddVideoThumbnailToMerchant < ActiveRecord::Migration
  def change
    add_column :merchants, :video_thumbnail_url, :string
  end
end
