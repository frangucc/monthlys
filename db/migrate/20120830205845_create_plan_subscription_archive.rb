class CreatePlanSubscriptionArchive < ActiveRecord::Migration
  def change
    create_table(:plan_subscription_archives) do |t|
      t.integer :plan_id, null: false
      t.string  :title,   null: false, default: ''
      t.date    :sent_on, null: false
      t.string  :image,   null: false, default: ''
      t.timestamps
    end
  end
end
