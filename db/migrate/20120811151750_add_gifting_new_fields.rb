class AddGiftingNewFields < ActiveRecord::Migration
  def up
    add_column :subscriptions, :notify_giftee_on_shipment, :boolean, null: false, default: false
    rename_column :subscriptions, :is_the_giftee_notified, :notify_giftee_on_email
    add_column :merchants, :custom_message_type, :string, default: 'none', null: false
  end

  def down
    remove_column :subscriptions, :notify_giftee_on_shipment
    rename_column :subscriptions, :notify_giftee_on_email, :is_the_giftee_notified
    remove_column :merchants, :custom_message_type
  end
end
