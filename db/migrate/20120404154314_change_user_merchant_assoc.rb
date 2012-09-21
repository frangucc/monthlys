class ChangeUserMerchantAssoc < ActiveRecord::Migration
  def up
    remove_column(:merchants, :user_id)
    add_column(:users, :merchant_id, :integer)
  end

  def down
    add_column(:merchants, :user_id, :integer)
    remove_column(:users, :merchant_id)
  end
end
