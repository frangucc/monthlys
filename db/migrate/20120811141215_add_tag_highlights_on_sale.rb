class AddTagHighlightsOnSale < ActiveRecord::Migration
  def change
    add_column(:tag_highlights, :on_sale, :boolean, nil: false, default: false)
  end
end
