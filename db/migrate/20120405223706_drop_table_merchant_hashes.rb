class DropTableMerchantHashes < ActiveRecord::Migration
  def up
    drop_table :merchant_hashes
  end

  def down
    create_table :merchant_hashes do |t|
      t.string :secret
      t.date :timestamp
      t.integer :merchant_id
    end
  end
end
