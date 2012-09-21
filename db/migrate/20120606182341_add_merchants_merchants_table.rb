class AddMerchantsMerchantsTable < ActiveRecord::Migration
  def change
    create_table "merchants_merchants", :force => true do |t|
      t.integer "merchant_id"
      t.integer "related_merchant_id"
    end
  end
end
