class RemoveUnnededFieldsFromShippingInfo < ActiveRecord::Migration
  def change
  	rename_column :shipping_infos, :zipcode, :zipcode_str
  	add_column :shipping_infos, :zipcode_id, :integer
  	remove_column :shipping_infos, :city
  	remove_column :shipping_infos, :state
  	remove_column :shipping_infos, :country
  end
end
