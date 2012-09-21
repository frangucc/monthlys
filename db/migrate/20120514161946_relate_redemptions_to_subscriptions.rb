class RelateRedemptionsToSubscriptions < ActiveRecord::Migration
  def change    
    rename_column :subscriptions, :coupon_id, :redemption_id
  end
end
