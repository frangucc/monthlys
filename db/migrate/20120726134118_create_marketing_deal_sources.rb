class CreateMarketingDealSources < ActiveRecord::Migration
  def change
    create_table :marketing_deal_sources do |t|
      t.string :url_code
      t.string :name
      t.string :image

      t.timestamps
    end

    add_index :marketing_deal_sources, :url_code
  end
end
