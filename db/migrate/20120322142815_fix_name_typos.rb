class FixNameTypos < ActiveRecord::Migration
  def up
    add_column :plan_recurrency, :recurrence_type, :string, limit: 40
    remove_column :plan_recurrency, :recurrency_type
    rename_table :plan_recurrency, :plan_recurrences
  end

  def down
    add_column :plan_recurrence, :recurrency_type, :string, limit: 40
    remove_column :plan_recurrence, :recurrence_type
    rename_table :plan_recurrences, :plan_recurrency
  end
end
