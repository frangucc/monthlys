class RecurlyPlansChanges < ActiveRecord::Migration
  def up
    remove_column :plans, :recurly_code
    add_column :plan_recurrences, :recurly_plan_code, :string, limit: 50
  end

  def down
    remove_column :plan_recurrences, :recurly_plan_code
    add_column :plans, :recurly_code, :string
  end
end
