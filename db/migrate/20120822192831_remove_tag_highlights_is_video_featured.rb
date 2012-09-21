class RemoveTagHighlightsIsVideoFeatured < ActiveRecord::Migration
  def up
    remove_column(:tag_highlights, :is_video_featured)
  end

  def down
    create_column(:tag_highlights, :is_video_featured, :boolean, null: false, default: false)
  end
end
