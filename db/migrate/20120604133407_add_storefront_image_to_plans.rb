class AddStorefrontImageToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :merchant_storefront_image, :string
  end
end
