class AddFeaturedFieldToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :is_featured, :boolean, default: false
  end
end
