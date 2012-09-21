class ChangeDefaultShippingOffset < ActiveRecord::Migration
  def change
    change_column :shipping_schedules, :offset, :integer, default: 15, null: false
  end
end
