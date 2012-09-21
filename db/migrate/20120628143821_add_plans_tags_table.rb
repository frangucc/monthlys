class AddPlansTagsTable < ActiveRecord::Migration
  def change
    create_table :plans_tags do |t|
      t.integer :plan_id
      t.integer :tag_id
    end
  end
end
