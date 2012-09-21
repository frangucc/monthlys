class ChangeInvoicesInvoiceNumberToInteger < ActiveRecord::Migration
  # Using PG raw sql to avoid cast errors.
  def up
    execute('ALTER TABLE invoices ALTER invoice_number TYPE integer USING invoice_number::int')
  end

  def down
    change_column(:invoices, :uuid, :string)
  end
end
