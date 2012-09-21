class RemoveShippingScheduleFields < ActiveRecord::Migration
  def up
    drop_table :shipping_schedules
  end

  def down
    create_table :shipping_schedules do |t|
      t.integer :merchant_id
      t.integer :offset, default: 2, null: false
      t.string  :weekly_shipping_dates
      t.string  :monthly_shipping_dates
      t.string  :schedule_type, default: 'daily'
    end
  end
end
