class CreateRedemptions < ActiveRecord::Migration
  def change
    create_table :redemptions do |t|
    	t.integer :coupon_id
    	t.integer :user_id
    	t.boolean :is_redeemed

      t.timestamps
    end
  end
end
