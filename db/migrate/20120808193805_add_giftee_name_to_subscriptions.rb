class AddGifteeNameToSubscriptions < ActiveRecord::Migration
  def change
    add_column(:subscriptions, :giftee_name, :string, null: false, default: '')
  end
end
