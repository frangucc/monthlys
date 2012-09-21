class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to :package
      t.belongs_to :user

      t.timestamps
    end
  end
end
