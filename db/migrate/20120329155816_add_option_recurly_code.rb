class AddOptionRecurlyCode < ActiveRecord::Migration
  def change
    add_column(:options, :recurly_code, :string, null: true, default: nil)
  end
end
