class AddIsActiveToShippingInfos < ActiveRecord::Migration

  def change
    add_column :shipping_infos, :is_active, :boolean, null: false, default: false
  end
end
