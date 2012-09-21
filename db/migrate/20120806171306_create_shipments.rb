class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.integer :subscription_id
      t.string :tracking_number

      t.timestamps
    end
  end
end
