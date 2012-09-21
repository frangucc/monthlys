class AddOffersAttributesToPlans < ActiveRecord::Migration
  def change
  	# Adding new plan columns
  	add_column :plans, :tagline, :string
  	add_column :plans, :thumbnail, :string
  	add_column :plans, :icon, :string
  	add_column :plans, :merchant_id, :integer

  	# Create new relationship plans-categories
  	create_table :categories_plans do |t|
  	  t.integer :plan_id
  	  t.integer :category_id
  	end
  	add_index :categories_plans, :plan_id
  	add_index :categories_plans, :category_id

  	# Add info columns on the merchant
  	add_column :merchants, :general_info, :text
  	add_column :merchants, :shipping_info, :text
  	add_column :merchants, :details, :text
  end
end
