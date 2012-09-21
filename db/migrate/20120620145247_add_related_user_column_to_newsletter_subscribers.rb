class AddRelatedUserColumnToNewsletterSubscribers < ActiveRecord::Migration
  def up
    remove_column :newsletter_subscribers, :source
    add_column :newsletter_subscribers, :related_user_id, :integer
  end

  def down
    add_column :newsletter_subscribers, :source, :string, null: false, default: ''
    remove_column :newsletter_subscribers, :related_user_id
  end
end
