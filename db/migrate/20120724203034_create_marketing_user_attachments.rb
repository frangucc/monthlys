class CreateMarketingUserAttachments < ActiveRecord::Migration
  def change
    create_table :marketing_user_attachments do |t|
      t.integer :user_id
      t.string :image, null: false
      t.string :attachment_type, null: false
      t.string :email, null: false, default: ''
      t.string :name, null: false, default: ''

      t.timestamps
    end

    add_index :marketing_user_attachments, :user_id
  end
end
