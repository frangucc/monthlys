class CreateNewsletterSubscribers < ActiveRecord::Migration
  def change
    create_table :newsletter_subscribers do |t|
      t.string :email, null: false, default: ''
      t.string :source, null: false, default: ''

      t.timestamps
    end
  end
end
