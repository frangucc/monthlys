class AddAboutImageFieldToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :about_image, :string
  end
end
