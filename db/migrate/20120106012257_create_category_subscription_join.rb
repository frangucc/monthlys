class CreateCategorySubscriptionJoin < ActiveRecord::Migration
  def change
    create_table :categories_subscriptions do |t|
      t.belongs_to :category,     :required => true
      t.belongs_to :subscription, :required => true
    end

    add_index :categories_subscriptions, :category_id
    add_index :categories_subscriptions, :subscription_id
  end
end
