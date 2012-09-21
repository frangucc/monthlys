class AddMarketingVideoReviewsTable < ActiveRecord::Migration
  def up
    create_table :marketing_video_reviews do |t|
      t.integer :plan_id
      t.string :raw_url
      t.string :title
      t.string :author
      t.boolean :is_active

      t.timestamps
    end
    add_index :marketing_video_reviews, :plan_id
  end

  def down
    drop_table :marketing_video_reviews
  end
end
