class AddSlugFieldToPlans < ActiveRecord::Migration
  def up
    add_column :plans, :slug, :string, null: false, default: ''
  end

  def down
    remove_column :plans, :slug
  end
end
