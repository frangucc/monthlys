class AddInvoicesSubscriptionM2m < ActiveRecord::Migration
  def up
    remove_column(:invoices, :subscription_id)
    create_table :invoices_subscriptions do |t|
      t.integer :invoice_id
      t.integer :subscription_id
    end
    add_column(:invoice_lines, :subscription_id, :integer, null: true, default: nil)
  end

  def down
    add_column(:invoices, :subscription_id, :integer, null: true, default: nil)
    drop_table(:invoices_subscriptions)
    remove_column(:invoice_lines, :subscription_id)
  end
end
