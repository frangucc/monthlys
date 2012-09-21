class AddTaxesBooleanFieldsToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :taxation_policy, :string, default: 'no_taxes'
  end
end
