class AddExactTargetIdToEmailRecipient < ActiveRecord::Migration
  def change
    add_column :email_recipients, :exact_target_id, :string
  end
end
