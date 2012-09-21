class CreateFaqs < ActiveRecord::Migration
  def change
    create_table :faqs do |t|
      t.string :question
      t.text :answer
      t.integer :order
      t.integer :merchant_id

      t.timestamps
    end
  end
end
