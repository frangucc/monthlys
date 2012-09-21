class RenameTypeColumns < ActiveRecord::Migration
  def change
    rename_column(:plans, :type, :plan_type)
    rename_column(:option_groups, :type, :option_type)
  end
end
