class ChangeInvoicesUuidToString < ActiveRecord::Migration
  def up
    change_column(:invoices, :uuid, :string)
  end

  def down
    execute('ALTER TABLE invoices ALTER uuid TYPE integer USING invoice_number::int')
  end
end
