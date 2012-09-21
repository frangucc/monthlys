class AddFieldsToPlans < ActiveRecord::Migration
  def up
    remove_column :plans, :frequency
    remove_column :plans, :our_cost
    remove_column :plans, :customer_cost

    rename_column :plans, :delivery_date, :next_expected_delivery_date

    add_column :plans, :interval_length, :integer
    add_column :plans, :interval_unit, :string
    add_column :plans, :unit_amount, :decimal
    add_column :plans, :total_billing_cycles, :integer
  end
  def down
    add_column :plans, :frequency, :integer
    add_column :plans, :our_cost, :decimal
    add_column :plans, :customer_cost, :decimal

    rename_column :plans, :next_expected_delivery_date, :delivery_date

    remove_column :plans, :interval_length
    remove_column :plans, :interval_unit
    remove_column :plans, :unit_amount_in_cents
    remove_column :plans, :total_billing_cycles
  end
end
