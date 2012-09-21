class AddGifteeNotificationEmailToSubscriptions < ActiveRecord::Migration
  def change
    add_column(:subscriptions, :is_the_giftee_notified, :boolean, null: false, default: false)
  end
end
