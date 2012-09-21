class AddStorefrontFieldsToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :tagline, :string
    add_column :merchants, :facebook_url, :string
    add_column :merchants, :twitter_url, :string
  end
end
