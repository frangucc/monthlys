class AddPlanRecurrenceIsActive < ActiveRecord::Migration
  def change
    add_column(:plan_recurrences, :is_active, :boolean, default: false)
  end
end
