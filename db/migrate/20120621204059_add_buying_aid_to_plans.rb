class AddBuyingAidToPlans < ActiveRecord::Migration
  def change
    add_column(:plans, :buying_aid, :string, null: false, default: '')
  end
end
