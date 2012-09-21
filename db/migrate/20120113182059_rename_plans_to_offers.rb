class RenamePlansToOffers < ActiveRecord::Migration
  def change
    rename_table :plans, :offers

    rename_column :categories, :plan_id, :offer_id
    rename_column :packages, :plan_id, :offer_id

    remove_index :categories_plans, :plan_id
    rename_table :categories_plans, :categories_offers
    rename_column :categories_offers, :plan_id, :offer_id
    add_index :categories_offers, :offer_id
  end
end
