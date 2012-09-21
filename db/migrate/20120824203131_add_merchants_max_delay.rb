class AddMerchantsMaxDelay < ActiveRecord::Migration
  def change
    add_column(:merchants, :max_delay, :integer , null: false, default: 20)
  end
end
