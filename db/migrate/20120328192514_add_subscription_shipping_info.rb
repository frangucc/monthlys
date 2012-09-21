class AddSubscriptionShippingInfo < ActiveRecord::Migration
  def change
    add_column(:subscriptions, :shipping_info_id, :integer, null: true, default: nil)
  end
end
