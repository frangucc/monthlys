class AddFieldToShippingInfo < ActiveRecord::Migration
  def change
  	add_column(:shipping_infos, :delivery_instructions, :string)
  end
end
