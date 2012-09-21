class AddTosToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :terms_of_service, :text
  end
end
