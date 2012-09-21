class AddNewTables < ActiveRecord::Migration
  def change
    create_table :plan_documents do |t|
      t.integer :plan_id
      t.string :name
      t.text :description
      t.string :file
    end

    create_table :plan_recurrency do |t|
      t.integer :plan_id
      t.string :recurrency_type, limit: 40
      t.decimal :amount, precision: 10, scale: 2
      t.string :status, limit: 20
    end

    create_table :plan_option_group do |t|
      t.integer :plan_id
      t.string :description
      t.string :type, limit: 20
      t.boolean :allow_multiple
      t.boolean :active
    end

    create_table :plan_option do |t|
      t.integer :plan_option_group_id
      t.string :title
      t.text :description
      t.decimal :amount, precision: 10, scale: 2, null: true
      t.string :image
      t.string :status, limit: 20
    end
  end
end
