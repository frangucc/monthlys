class AddMerchantsStatesRelation < ActiveRecord::Migration
  def change
    create_table :merchants_states do |t|
      t.integer :merchant_id
      t.integer :state_id
    end
  end
end
