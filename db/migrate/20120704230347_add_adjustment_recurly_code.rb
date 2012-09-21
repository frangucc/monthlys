class AddAdjustmentRecurlyCode < ActiveRecord::Migration
  def change
    add_column(:adjustments, :recurly_code, :string, limit: 50, default: '', null: true)
  end
end
