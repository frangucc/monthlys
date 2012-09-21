class AddHeadingToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :storefront_heading, :string
  end
end
