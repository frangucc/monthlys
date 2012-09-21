class AddTagHighlightsPriceFields < ActiveRecord::Migration
  def up
    add_column(:tag_highlights, :price_amount, :decimal, nil: true, default: nil)
    add_column(:tag_highlights, :price_recurrence, :string, nil: false, default: '')
    add_column(:tag_highlights, :ordering, :integer, nil: false, default: 0)
    remove_column(:tag_highlights, :price)
  end

  def down
    remove_column(:tag_highlights, :price_amount)
    remove_column(:tag_highlights, :price_recurrence)
    remove_column(:tag_highlights, :ordering)
    add_column(:tag_highlights, :price, :string)
  end
end
