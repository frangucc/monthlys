class CreateShippingInfos < ActiveRecord::Migration
  def change
    create_table :shipping_infos do |t|
      t.boolean :is_default
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :country
      t.string :zipcode
      t.string :phone

      t.timestamps
    end
  end
end
