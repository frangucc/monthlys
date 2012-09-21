class ChangeDescriptionFields < ActiveRecord::Migration
  def up
    change_column :subscriptions, :general_info, :text
    change_column :subscriptions, :shipping_info, :text
    change_column :subscriptions, :details, :text
  end

  def down
    change_column :subscriptions, :general_info, :string
    change_column :subscriptions, :shipping_info, :string
    change_column :subscriptions, :details, :string
  end
end
