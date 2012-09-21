class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :order_batch_id

      t.datetime :created_at
      t.string :billing_status
      t.datetime :cancellation_date
      t.datetime :expiration_date
      t.datetime :renewal_date
      t.datetime :next_order_date
      t.string :user_last_name
      t.string :user_first_name
      t.string :user_email
      t.string :shipping_first_name
      t.string :shipping_last_name
      t.string :shipping_address_1
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      t.string :shipping_phone
      t.boolean :is_gift
      t.string :giftee_name
      t.string :giftee_email
      t.string :gift_message
      t.boolean :notify_giftee_on_email
      t.boolean :notify_giftee_on_shipment
      t.string :plan_name
      t.string :option_1a
      t.string :option_1b
      t.string :option_2a
      t.string :option_2b
      t.string :option_3a
      t.string :option_3b
      t.string :option_4a
      t.string :option_4b
      t.string :option_5a
      t.string :option_5b
      t.string :shipping_frequency
      t.decimal :base_price
      t.decimal :shipping
      t.decimal :taxes
      t.decimal :recurrent_total
      t.decimal :first_time_total
      t.string :coupon_code
      t.string :last_payment_date
      t.decimal :last_payment_amount
      t.string :cc_type
      t.string :cc_last_4
      t.date :cc_exp_date
      t.decimal :commission_rate
      t.decimal :merchant_first_installment
      t.string :user_recurly_code
      t.string :subscription_recurly_code
    end
  end
end
