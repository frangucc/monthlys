class AddGifteeEmailFieldToSubscription < ActiveRecord::Migration
  def up
    add_column :subscriptions, :giftee_email, :string, null: false, default: ''
  end

  def down
    remove_column :subscriptions, :giftee_email
  end
end
