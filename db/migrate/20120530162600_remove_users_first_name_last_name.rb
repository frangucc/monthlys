class RemoveUsersFirstNameLastName < ActiveRecord::Migration
  def up
    add_column(:users, :full_name, :string)

    # Data migration
    ActiveRecord::Base.connection.execute("UPDATE users SET full_name=first_name || ' ' || last_name")

    remove_column(:users, :first_name)
    remove_column(:users, :last_name)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
