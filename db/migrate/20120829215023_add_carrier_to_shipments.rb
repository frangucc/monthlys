class AddCarrierToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :carrier, :string, null: false, default: ''
  end
end
