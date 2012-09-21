class CreateTableMerchantHashes < ActiveRecord::Migration
  def up
    create_table :merchant_hashes do |t|
      t.string :secret
      t.date :timestamp
      t.integer :merchant_id
    end
  end

  def down
    drop_table :merchant_hashes
  end
end
