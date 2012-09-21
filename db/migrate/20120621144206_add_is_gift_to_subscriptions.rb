class AddIsGiftToSubscriptions < ActiveRecord::Migration
  def up
    add_column :subscriptions, :is_gift, :boolean, null: false, default: false
    add_column :subscriptions, :gift_description, :text
  end

  def down
    remove_column :subscriptions, :is_gift
    remove_column :subscriptions, :gift_description
  end
end
