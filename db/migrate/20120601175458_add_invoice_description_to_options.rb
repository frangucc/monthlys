class AddInvoiceDescriptionToOptions < ActiveRecord::Migration
  def change
    add_column :options, :invoice_description, :string
  end
end
