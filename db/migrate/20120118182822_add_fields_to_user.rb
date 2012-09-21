class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string
    add_column :users, :company_name, :string
  end
end
