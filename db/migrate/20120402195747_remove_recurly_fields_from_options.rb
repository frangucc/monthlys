class RemoveRecurlyFieldsFromOptions < ActiveRecord::Migration
  def up
    remove_column(:options, [:recurly_code, :status])
  end

  def down
    add_column(:options, :recurly_code, :string, null: true, default: nil)
    add_column(:options, :status, :string, limit: 20)
  end
end
