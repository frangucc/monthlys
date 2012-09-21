class AddCcLastFourToSubscriptions < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.string :cc_last_four, null: false, default: ''
      t.string :cc_type, null: false, default: ''
      t.string :cc_exp_date, null: false, default: ''
    end
  end
end
