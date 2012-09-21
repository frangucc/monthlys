class AddFeaturedToCities < ActiveRecord::Migration
  def change
  	add_column :cities, :is_featured, :boolean, :null => false, :default => false
  end
end
