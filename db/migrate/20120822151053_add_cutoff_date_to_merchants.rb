class AddCutoffDateToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :cutoff_day, :integer, null: false, default: 15
  end
end
