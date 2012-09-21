class AddStateIdToCities < ActiveRecord::Migration
  def change
    add_column :cities, :state_id, :integer
    rename_column :cities, :state, :state_code
  end
end
