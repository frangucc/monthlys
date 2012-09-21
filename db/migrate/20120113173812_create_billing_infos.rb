class CreateBillingInfos < ActiveRecord::Migration
  def change
    create_table :billing_infos do |t|
      t.integer :user_id
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :month
      t.string :year
      t.string :ip_address

      t.timestamps
    end
  end
end
