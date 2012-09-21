class CreateMarketingNewsletters < ActiveRecord::Migration
  def change
    create_table :marketing_newsletters do |t|
      t.string :heading, null: false, default: ''
      t.string :subheading, null: false, default: ''

      # Custom space
      t.text :main_content, null: false, default: ''
      t.string :main_image, null: false, default: ''
      t.string :main_image_link, null: false, default: ''

      # Featured plan and coupon
      t.integer :plan_id
      t.integer :coupon_id
      t.string :the_value, null: false, default: ''
      t.string :featured_price, null: false, default: ''
      t.string :featured_billing_cycle, null: false, default: ''
      t.string :footnote, null: false, default: ''

      # 3 block space
      t.string :first_block_heading, null: false, default: ''
      t.string :first_block_link, null: false, default: ''
      t.string :first_block_image, null: false, default: ''
      t.string :first_block_description, null: false, default: ''

      t.string :second_block_heading, null: false, default: ''
      t.string :second_block_link, null: false, default: ''
      t.string :second_block_image, null: false, default: ''
      t.string :second_block_description, null: false, default: ''

      t.string :third_block_heading, null: false, default: ''
      t.string :third_block_link, null: false, default: ''
      t.string :third_block_image, null: false, default: ''
      t.string :third_block_description, null: false, default: ''

      # Show getting started steps?
      t.boolean :show_getting_started_steps, null: false, default: false

      t.timestamps
    end
  end
end
