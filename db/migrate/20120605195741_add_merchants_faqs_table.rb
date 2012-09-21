class AddMerchantsFaqsTable < ActiveRecord::Migration
  def up
    create_table "faqs_merchants", :force => true do |t|
      t.integer "faq_id"
      t.integer "merchant_id"
    end

    add_index "faqs_merchants", ["faq_id"], :name => "index_faqs_merchants_on_faq_id"
    add_index "faqs_merchants", ["merchant_id"], :name => "index_faqs_merchants_on_merchant_id"

    remove_column :faqs, :merchant_id
  end

  def down
    remove_index "faqs_merchants", ["faq_id"]
    remove_index "faqs_merchants", ["merchant_id"]
    drop_table :faqs_merchants
    add_column :faqs, :merchant_id, :integer
  end
end
