class EditPlanFields < ActiveRecord::Migration
  def change
  	rename_column :plans, :state, :status
  	rename_column :plan_option_group, :active, :is_active
  	rename_column :plan_option, :plan_option_group_id, :option_group_id
  	rename_table :plan_option_group, :option_groups
  	rename_table :plan_option, :options
  	rename_table :plan_documents, :documents
  end
end
