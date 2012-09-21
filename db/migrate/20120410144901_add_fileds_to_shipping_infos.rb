class AddFiledsToShippingInfos < ActiveRecord::Migration
  def change
  	add_column(:shipping_infos, :city, :string)
  	add_column(:shipping_infos, :state, :string)
  end
end
