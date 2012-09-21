class AddStateToPlans < ActiveRecord::Migration

  def up
    add_column :plans, :state, :string, :default => 'pending'
    add_column :plans, :unique_hash, :string
  end

  def down
    remove_column :plans, :state
    remove_column :plans, :unique_hash
  end
end
