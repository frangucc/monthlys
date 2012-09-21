class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :user_id
      t.integer :uuid
      t.string :status
      t.decimal :subtotal_in_dollars
      t.decimal :tax_in_dollars
      t.decimal :total_in_dollars

      t.timestamps
    end
  end
end
