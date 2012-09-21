class AddMoreFieldsToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :trial_interval_length, :integer
    add_column :plans, :trial_interval_unit, :string
    add_column :plans, :setup_fee, :decimal
    add_column :plans, :unit_name, :string
    add_column :plans, :display_quantity, :boolean
    add_column :plans, :recurly_reference_name, :string
    add_column :plans, :recurly_description, :string
  end
end
