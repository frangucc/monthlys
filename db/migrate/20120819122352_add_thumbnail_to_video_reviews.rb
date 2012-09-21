class AddThumbnailToVideoReviews < ActiveRecord::Migration
  def change
    add_column(:marketing_video_reviews, :thumbnail, :string, null: false, default: '')
    add_column(:marketing_video_reviews, :is_featured, :boolean, default: false)
  end
end
