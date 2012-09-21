class CreateShippingPrices < ActiveRecord::Migration
  def change
    create_table :shipping_prices do |t|
      t.integer :merchant_id
      t.string :state
      t.decimal :percentage
      t.decimal :amount_in_cents

      t.timestamps
    end
  end
end
