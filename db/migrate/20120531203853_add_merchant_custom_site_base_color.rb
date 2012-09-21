class AddMerchantCustomSiteBaseColor < ActiveRecord::Migration
  def change
    add_column(:merchants, :custom_site_base_color, :string, limit: 6, null:true, default: nil)
  end
end
