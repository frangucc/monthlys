class ChangeCouponsAppliesToAllPlansDefaultTrue < ActiveRecord::Migration
  def up
    change_column(:coupons, :applies_to_all_plans, :boolean, default:true, null: false)
  end

  def down
    change_column(:coupons, :applies_to_all_plans, :boolean)
  end
end
