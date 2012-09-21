class CreateSubscriptionEditions < ActiveRecord::Migration
  def change
    create_table :subscription_editions do |t|
      t.integer :subscription_id, null: false
      t.text :attributes_data
      t.text :pricing_data

      t.timestamps
    end
  end
end
