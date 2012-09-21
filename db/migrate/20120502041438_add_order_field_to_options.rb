class AddOrderFieldToOptions < ActiveRecord::Migration
  def change
  	add_column :options, :order, :integer
  	add_column :option_groups, :order, :integer
  end
end
