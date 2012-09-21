class AddSubscriptionsUserNote < ActiveRecord::Migration
  def change
    add_column :subscriptions, :user_note, :text
  end
end
