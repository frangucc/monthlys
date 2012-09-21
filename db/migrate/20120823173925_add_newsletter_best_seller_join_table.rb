class AddNewsletterBestSellerJoinTable < ActiveRecord::Migration
  def up
    create_table 'best_sellers_newsletters', :id => false do |t|
      t.column :best_seller_id, :integer
      t.column :newsletter_id, :integer
    end
  end

  def down
    drop_table 'best_sellers_newsletters'
  end
end
