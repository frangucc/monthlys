class AddInitialCountToPlans < ActiveRecord::Migration
  def change
  	add_column :plans, :initial_count, :integer, :null => false, :default => 0
  end
end
