class AddSlugToTags < ActiveRecord::Migration
  def change
    change_table :tags do |t|
      t.string :slug, null: false, default: ''
    end
  end
end
