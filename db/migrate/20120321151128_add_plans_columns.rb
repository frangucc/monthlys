class AddPlansColumns < ActiveRecord::Migration
  def change
    add_column :plans, :type, :string, limit: 40
    add_column :plans, :terms, :text
    add_column :plans, :fine_print, :text
    add_column :plans, :extra_notes, :boolean
    add_column :plans, :shipping_type, :string, limit: 10
    add_column :plans, :shipping_rate, :decimal, precision: 7, scale: 2
  end
end
