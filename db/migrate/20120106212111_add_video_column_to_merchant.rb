class AddVideoColumnToMerchant < ActiveRecord::Migration
  def change
    add_column :merchants, :video_url, :string
  end
end
