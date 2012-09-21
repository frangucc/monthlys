class AddTagHighlightsIsActive < ActiveRecord::Migration
  def change
    add_column(:tag_highlights, :is_active, :boolean, default: true, null: false)
  end
end
