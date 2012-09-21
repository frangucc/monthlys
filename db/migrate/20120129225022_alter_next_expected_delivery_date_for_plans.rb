class AlterNextExpectedDeliveryDateForPlans < ActiveRecord::Migration
  def change
    remove_column :plans, :next_expected_delivery_date
    add_column :plans, :delivery_interval_length, :integer
    add_column :plans, :delivery_interval_unit, :string
  end
end
