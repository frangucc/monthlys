class AddSuperhubGroupLabel < ActiveRecord::Migration
  def change
    add_column(:superhub_plan_groups, :label, :string, null: false, default: '')
  end
end
