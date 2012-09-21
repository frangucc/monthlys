class CreateShippingSchedules < ActiveRecord::Migration
  def change
    create_table :shipping_schedules do |t|
      t.integer :merchant_id
      t.integer :offset
      t.string :weekly_shipping_dates
      t.string :monthly_shipping_dates
      t.string :schedule_type, default: "daily"
    end
  end
end
