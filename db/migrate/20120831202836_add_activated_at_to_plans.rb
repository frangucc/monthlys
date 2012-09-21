class AddActivatedAtToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :activated_at, :date, default: nil
  end
end
