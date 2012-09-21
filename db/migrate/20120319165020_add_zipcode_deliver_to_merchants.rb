class AddZipcodeDeliverToMerchants < ActiveRecord::Migration
  def change
  	create_table :zipcodes do |t|
  		t.string :number
  		t.integer :city_id
  	end

  	create_table :merchants_zipcodes do |t|
  		t.integer :merchant_id
  		t.integer :zipcode_id
  	end
  end
end
