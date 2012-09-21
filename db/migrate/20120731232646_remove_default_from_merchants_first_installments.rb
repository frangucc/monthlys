class RemoveDefaultFromMerchantsFirstInstallments < ActiveRecord::Migration
  def up
    change_column :merchants, :first_installment, :integer, default: nil, null: true
  end

  def down
    change_column :merchants, :first_installment, :integer, default: 0, null: false
  end
end
