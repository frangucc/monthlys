class ChangeZipcodeToZipcodeStrToUsers < ActiveRecord::Migration
  def change
  	rename_column :users, :zipcode, :zipcode_str
  end
end
