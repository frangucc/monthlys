class CreateInvoiceLines < ActiveRecord::Migration
  def change
    create_table :invoice_lines do |t|
      t.integer :invoice_id
      t.string :uuid, limit: 32
      t.string :description
      t.string :origin
      t.decimal :unit_amount_in_usd, precision: 10, scale: 2
      t.integer :quantity
      t.decimal :discount_in_usd, precision: 10, scale: 2
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :recurly_created_at
      t.timestamps
    end
  end
end
