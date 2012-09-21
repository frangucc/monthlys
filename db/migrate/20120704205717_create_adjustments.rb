class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.integer :subscription_id
      t.string :adjustment_type, null: false, default: ''
      t.string :description, null: false, default: ''
      t.decimal :amount_in_usd

      t.timestamps
    end
  end
end
