class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :invoice_id
      t.integer :uuid
      t.integer :action
      t.decimal :amount_in_dollars
      t.decimal :tax_in_dollars
      t.string :status
      t.string :reference
      t.string :source
      t.boolean :test
      t.boolean :voidable
      t.boolean :refundable

      t.timestamps
    end
  end
end
