class AlterPlanFields < ActiveRecord::Migration
  def change
    rename_column :plans, :recurly_description, :marketing_phrase
  end
end
