class CreateMarketingBestSellers < ActiveRecord::Migration
  def change
    create_table :marketing_best_sellers do |t|
      t.integer :plan_id
      t.integer :coupon_id
      t.integer :order

      t.timestamps
    end
  end
end
