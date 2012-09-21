class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.integer :frequency
      t.decimal :our_cost
      t.decimal :customer_cost
      t.date :delivery_date

      # Relations
      t.integer :subscription_id

      t.timestamps
    end
  end
end
