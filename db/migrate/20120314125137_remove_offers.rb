class RemoveOffers < ActiveRecord::Migration
  def up
  	drop_table :offers
  	# Removing useless column
  	remove_column :categories, :offer_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
