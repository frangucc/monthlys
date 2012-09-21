class ChangeActionColumnForTransactions < ActiveRecord::Migration
  def up
    change_column(:transactions, :action, :string, default:'', null: false)
    change_column(:transactions, :recurly_code, :string, default:'', null: false)
  end

  def down
    change_column(:transactions, :action, :integer, default:1, null: false)
    change_column(:transactions, :recurly_code, :integer, null: false)
  end
end
