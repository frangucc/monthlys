class AddFakePriceToPlanRecurrences < ActiveRecord::Migration
  def change
    add_column(:plan_recurrences, :fake_amount, :decimal, precision: 10, scale: 2)
  end
end
