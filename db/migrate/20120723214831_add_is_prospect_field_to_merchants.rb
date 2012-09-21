class AddIsProspectFieldToMerchants < ActiveRecord::Migration
  def change
    add_column(:merchants, :is_prospect, :boolean, default: false)
  end
end
