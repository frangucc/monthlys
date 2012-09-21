class ChangeInvoiceColumns < ActiveRecord::Migration
  def up
    remove_column(:invoices, :tax_in_dollars)

    change_column(:invoices, :subtotal_in_dollars, :decimal,  scale:  2, precision: 10)
    change_column(:invoices, :total_in_dollars, :decimal,  scale:  2, precision: 10)

    rename_column(:invoices, :total_in_dollars, :total_in_usd)
    rename_column(:invoices, :subtotal_in_dollars, :subtotal_in_usd)
  end

  def down
    rename_column(:invoices, :total_in_usd, :total_in_dollars)
    rename_column(:invoices, :subtotal_in_usd, :subtotal_in_dollars)

    change_column(:invoices, :subtotal_in_dollars, :decimal)
    change_column(:invoices, :total_in_dollars, :decimal)

    add_column(:invoices, :tax_in_dollars, :decimal)
  end
end
