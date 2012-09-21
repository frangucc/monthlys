class CreateOrderBatches < ActiveRecord::Migration
  def change
    create_table :order_batches do |t|
      t.integer :merchant_id
      t.date :order_date

      t.timestamps
    end
  end
end
