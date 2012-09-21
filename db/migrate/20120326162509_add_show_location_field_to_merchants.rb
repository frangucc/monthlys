class AddShowLocationFieldToMerchants < ActiveRecord::Migration
  def change
  	add_column :merchants, :show_location, :boolean, :default => true
  end
end
