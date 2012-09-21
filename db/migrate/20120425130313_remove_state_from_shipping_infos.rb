class RemoveStateFromShippingInfos < ActiveRecord::Migration
  def change
    remove_column :shipping_infos, :state
  end
end
