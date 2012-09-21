class AddIsActiveFieldToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :is_active, :boolean
  end
end
