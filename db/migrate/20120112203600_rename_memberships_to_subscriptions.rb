class RenameMembershipsToSubscriptions < ActiveRecord::Migration
  def change
    rename_table :memberships, :subscriptions
  end
end
