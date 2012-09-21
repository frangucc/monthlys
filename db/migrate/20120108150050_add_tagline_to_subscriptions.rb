class AddTaglineToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :tagline, :string
  end
end
