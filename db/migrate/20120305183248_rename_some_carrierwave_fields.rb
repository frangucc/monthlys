class RenameSomeCarrierwaveFields < ActiveRecord::Migration
  def change
    rename_column :merchants, :merchant_image, :image
    rename_column :plans, :plan_image, :image
  end
end
