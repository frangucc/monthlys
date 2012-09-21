class AddDeliveryRadiusToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :delivery_radius, :decimal, :scale => 2, :precision => 6
    add_column :merchants, :delivery_type, :integer, :null => false, :default => Merchant::DELIVERY_TYPE::NATIONWIDE
  end
end
