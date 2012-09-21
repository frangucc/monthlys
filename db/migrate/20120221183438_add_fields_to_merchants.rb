class AddFieldsToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :business_size, :string
    add_column :merchants, :management_config, :string
    add_column :merchants, :assistance_config, :string
    add_column :merchants, :delivery_config_id, :integer
    add_column :merchants, :marketplace, :boolean
    add_column :merchants, :custom_site, :boolean
    add_column :merchants, :point_of_sale, :boolean
    add_column :merchants, :about, :text
  end
end
