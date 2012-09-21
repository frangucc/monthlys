class AddOrderToPlanAttachments < ActiveRecord::Migration
  def change
    add_column(:attachments, :order, :integer)
  end
end
