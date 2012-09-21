class CreateTaxRates < ActiveRecord::Migration
  def change
    create_table :tax_rates do |t|
      t.integer  "merchant_id"
      t.integer  "state_id"
      t.decimal  "percentage"

      t.timestamps
    end
  end
end
