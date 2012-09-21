class AddInvoicesSubscription < ActiveRecord::Migration
  def change
    add_column(:invoices, :subscription_id, :integer, null: true, default: nil)
  end
end
