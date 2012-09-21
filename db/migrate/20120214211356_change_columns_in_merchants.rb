class ChangeColumnsInMerchants < ActiveRecord::Migration
  def change
    rename_column :merchants, :name, :business_name
    add_column :merchants, :address1, :string
    add_column :merchants, :address2, :string
    add_column :merchants, :zipcode, :string
    add_column :merchants, :city, :string
    add_column :merchants, :country, :string
    add_column :merchants, :state, :string
    add_column :merchants, :phone, :string
    add_column :merchants, :contact_name, :string
    add_column :merchants, :contact_last_name, :string
    add_column :merchants, :website, :string
    add_column :merchants, :business_type, :string
    add_column :merchants, :comments, :text
  end
end
