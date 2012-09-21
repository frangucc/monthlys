class RemoveBatchOrderModels < ActiveRecord::Migration
  def up
    drop_table :order_batches
    drop_table :orders
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
