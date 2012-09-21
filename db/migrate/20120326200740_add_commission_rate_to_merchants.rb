class AddCommissionRateToMerchants < ActiveRecord::Migration
  def change
  	add_column :merchants, :commission_rate, :decimal
  end
end
