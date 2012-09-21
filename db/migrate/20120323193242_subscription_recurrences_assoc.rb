class SubscriptionRecurrencesAssoc < ActiveRecord::Migration
  def up
    add_column(:subscriptions, :plan_recurrence_id, :integer)
    change_column(:subscriptions, :recurly_code, :string, null: true, default: nil)
  end

  def down
    remove_column(:subscriptions, :plan_recurrence_id)
    change_column(:subscriptions, :recurly_code, :string, null: false, default: '')
  end
end
