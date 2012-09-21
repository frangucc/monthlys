class EditPlansAndMerchantsFields < ActiveRecord::Migration
  def change
    add_column(:plans, :short_description, :string)
    add_column(:merchants, :marketing_phrase, :string)
  end
end
