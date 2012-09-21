class CreateEmailRecipients < ActiveRecord::Migration
  def change
    create_table :email_recipients do |t|
      t.string :email
      t.text :profile_attributes
      t.string :emailable_type
      t.integer :emailable_id

      t.timestamps
    end
  end
end
