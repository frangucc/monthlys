class AddCustomUrlFieldToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :custom_site_url, :string
  end
end
