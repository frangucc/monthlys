class AddInvoicesInvoiceNumber < ActiveRecord::Migration
  def change
    add_column :invoices, :invoice_number, :string
  end
end
