class AddMerchantFirstInstallmentToMerchants < ActiveRecord::Migration
  def change
    change_table :merchants do |t|
      t.integer :first_installment, null: false, default: 0
    end
  end
end
