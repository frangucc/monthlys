class AlterTransactions < ActiveRecord::Migration
  def change
    rename_column(:transactions, :uuid, :recurly_code)
    rename_column(:transactions, :amount_in_dollars, :amount)
    remove_column(:transactions, :tax_in_dollars)
    remove_column(:transactions, :status)
    remove_column(:transactions, :reference)
    remove_column(:transactions, :source)
    remove_column(:transactions, :test)
    remove_column(:transactions, :voidable)
    remove_column(:transactions, :refundable)
  end
end
