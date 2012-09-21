class SetIsActiveDeafaultToFalse < ActiveRecord::Migration
  def up
  	change_column :options, :is_active, :boolean, default: false
  	change_column :option_groups, :is_active, :boolean, default: false
  	change_column :plan_recurrences, :is_active, :boolean, default: false
  	change_column :coupons, :is_active, :boolean, default: false
  	change_column :merchants, :is_active, :boolean, default: false
  	change_column :users, :is_active, :boolean, default: false
  end
  def down
  	change_column :options, :is_active, :boolean
  	change_column :option_groups, :is_active, :boolean
  	change_column :plan_recurrences, :is_active, :boolean
  	change_column :coupons, :is_active, :boolean
  	change_column :merchants, :is_active, :boolean
  	change_column :users, :is_active, :boolean
  end
end
