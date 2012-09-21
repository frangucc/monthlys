class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :keyword
      t.boolean :is_featured

      t.timestamps
    end
  end
end
