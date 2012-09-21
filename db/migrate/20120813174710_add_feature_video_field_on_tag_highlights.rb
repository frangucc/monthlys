class AddFeatureVideoFieldOnTagHighlights < ActiveRecord::Migration
  def change
    add_column(:tag_highlights, :is_video_featured, :boolean, nil: false, default: false)
  end
end
