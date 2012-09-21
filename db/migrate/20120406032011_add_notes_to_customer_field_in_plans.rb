class AddNotesToCustomerFieldInPlans < ActiveRecord::Migration
  def change
  	add_column(:plans, :notes_to_customer, :string)
  end
end
