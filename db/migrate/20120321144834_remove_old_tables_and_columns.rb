class RemoveOldTablesAndColumns < ActiveRecord::Migration
  def up
    # Drop old tables
    drop_table :categories_offers
    # Plans
    remove_column :plans, :offer_id
    remove_column :plans, :interval_length
    remove_column :plans, :interval_unit
    remove_column :plans, :unit_amount
    remove_column :plans, :total_billing_cycles
    remove_column :plans, :trial_interval_length
    remove_column :plans, :trial_interval_unit
    remove_column :plans, :setup_fee
    remove_column :plans, :delivery_interval_length
    remove_column :plans, :delivery_interval_unit
    remove_column :plans, :unit_name
    remove_column :plans, :display_quantity
    remove_column :plans, :marketing_phrase
    # Subcriptions
    remove_column :subscriptions, :plan_id
    # Merchants
    remove_column :merchants, :delivery_config_id
    remove_column :merchants, :delivery_radius
  end
end
