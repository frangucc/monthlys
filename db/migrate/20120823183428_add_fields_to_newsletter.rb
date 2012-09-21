class AddFieldsToNewsletter < ActiveRecord::Migration
  def change
    add_column(:marketing_newsletters, :subject, :string, null: false, default: '')
  end
end
