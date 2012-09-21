class ChangeShippingPricesToPointToAState < ActiveRecord::Migration
  def change
    add_column :shipping_prices, :state_id, :integer
    remove_column :shipping_prices, :state
    change_column :merchants, :shipping_type, :string, limit: 20
  end
end
