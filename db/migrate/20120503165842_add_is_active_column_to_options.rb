class AddIsActiveColumnToOptions < ActiveRecord::Migration
  def change
  	add_column :options, :is_active, :boolean
  end
end
