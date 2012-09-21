class AddSuperhubPlanTitles < ActiveRecord::Migration
  def change
    add_column(:superhub_plans, :title, :string, default: '', null: true)
    add_column(:superhub_plans, :subtitle, :string, default: '', null: true)
  end
end
