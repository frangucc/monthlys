class AddOptionRecurlyCodes < ActiveRecord::Migration
  def change
    create_table :option_recurly_codes do |t|
      t.integer :plan_recurrence_id
      t.integer :option_id
      t.string  :recurly_code, null: false, default: ''
      t.string  :status, limit: 20
    end
  end
end
