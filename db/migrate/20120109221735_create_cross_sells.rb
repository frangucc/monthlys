class CreateCrossSells < ActiveRecord::Migration
  def change
    create_table :cross_sells do |t|
      t.integer :category_id
      t.integer :related_category_id

      t.timestamps
    end
  end
end
