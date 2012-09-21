class AddLogoToCustomStorefront < ActiveRecord::Migration
  def change
    add_column :merchants, :storefront_logo, :string
  end
end
