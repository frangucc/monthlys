class AddGoogleNameToCities < ActiveRecord::Migration
  def change
    add_column :cities, :google_name, :string
  end
end
