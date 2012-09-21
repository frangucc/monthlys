class CreateRegistry < ActiveRecord::Migration
  def change
    create_table :registry do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end
