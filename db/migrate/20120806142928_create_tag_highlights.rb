class CreateTagHighlights < ActiveRecord::Migration
  def change
    create_table :tag_highlights do |t|
      t.integer :tag_id
      t.string :image
      t.string :title
      t.string :price
      t.string :highlight_type
      t.integer :plan_id
      t.integer :category_id
      t.timestamps
    end
  end
end
