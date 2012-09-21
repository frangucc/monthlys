class CreateMerchantsAndCitiesJoin < ActiveRecord::Migration
  def up
    create_table 'cities_merchants', :id => false do |t|
      t.column :city_id, :integer
      t.column :merchant_id, :integer
    end
  end

  def down
    drop_table 'cities_merchants'
  end
end
