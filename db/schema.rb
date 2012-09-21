# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120903191844) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "adjustments", :force => true do |t|
    t.integer  "subscription_id"
    t.string   "adjustment_type",               :default => "", :null => false
    t.string   "description",                   :default => "", :null => false
    t.decimal  "amount_in_usd"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recurly_code",    :limit => 50, :default => "", :null => false
  end

  create_table "admin_activities", :force => true do |t|
    t.string   "verb",                :default => "", :null => false
    t.integer  "admin_user_id"
    t.integer  "object_id"
    t.string   "object_type",         :default => "", :null => false
    t.text     "previous_attributes"
    t.text     "new_attributes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "attachments", :force => true do |t|
    t.string   "image",           :default => "", :null => false
    t.integer  "attachable_id"
    t.string   "attachable_type", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
  end

  add_index "attachments", ["attachable_id"], :name => "index_attachments_on_attachable_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider",   :default => "", :null => false
    t.string   "uid",        :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "best_sellers_newsletters", :id => false, :force => true do |t|
    t.integer "best_seller_id"
    t.integer "newsletter_id"
  end

  create_table "billing_infos", :force => true do |t|
    t.integer  "user_id"
    t.string   "address1",   :default => "", :null => false
    t.string   "address2",   :default => "", :null => false
    t.string   "city",       :default => "", :null => false
    t.string   "state",      :default => "", :null => false
    t.string   "zip",        :default => "", :null => false
    t.string   "month",      :default => "", :null => false
    t.string   "year",       :default => "", :null => false
    t.string   "ip_address", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name",              :default => "", :null => false
    t.string   "image",             :default => "", :null => false
    t.string   "thumbnail",         :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_featured"
    t.string   "icon",              :default => "", :null => false
    t.integer  "category_group_id"
    t.string   "header_image",      :default => "", :null => false
  end

  create_table "categories_plans", :force => true do |t|
    t.integer "plan_id"
    t.integer "category_id"
  end

  add_index "categories_plans", ["category_id"], :name => "index_categories_plans_on_category_id"
  add_index "categories_plans", ["plan_id"], :name => "index_categories_plans_on_plan_id"

  create_table "category_groups", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.string   "image",      :default => "", :null => false
    t.string   "icon",       :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string  "name",        :default => "",    :null => false
    t.string  "state_code",  :default => "",    :null => false
    t.string  "image",       :default => "",    :null => false
    t.boolean "is_featured", :default => false, :null => false
    t.string  "google_name", :default => "",    :null => false
    t.integer "state_id"
  end

  create_table "cities_merchants", :id => false, :force => true do |t|
    t.integer "city_id"
    t.integer "merchant_id"
  end

  create_table "coupons", :force => true do |t|
    t.string   "coupon_code",                                           :default => "",    :null => false
    t.string   "name",                                                  :default => "",    :null => false
    t.string   "marketing_description",                                 :default => "",    :null => false
    t.string   "invoice_description",                                   :default => "",    :null => false
    t.date     "redeem_by_date"
    t.boolean  "single_use",                                            :default => true,  :null => false
    t.integer  "applies_for_months"
    t.integer  "max_redemptions"
    t.boolean  "applies_to_all_plans",                                  :default => true,  :null => false
    t.string   "discount_type",                                         :default => "",    :null => false
    t.integer  "discount_percent"
    t.decimal  "discount_in_usd",        :precision => 10, :scale => 2
    t.boolean  "is_active",                                             :default => false
    t.string   "image",                                                 :default => "",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recurly_code",                                          :default => "",    :null => false
    t.boolean  "available_to_all_users",                                :default => false, :null => false
  end

  create_table "coupons_plans", :force => true do |t|
    t.integer "plan_id"
    t.integer "coupon_id"
  end

  create_table "cross_sells", :force => true do |t|
    t.integer  "category_id"
    t.integer  "related_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.integer "plan_id"
    t.string  "name",        :default => "", :null => false
    t.text    "description"
    t.string  "file",        :default => "", :null => false
  end

  create_table "email_recipients", :force => true do |t|
    t.string   "email",              :default => "", :null => false
    t.text     "profile_attributes"
    t.string   "emailable_type",     :default => "", :null => false
    t.integer  "emailable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "exact_target_id",    :default => "", :null => false
  end

  create_table "faqs", :force => true do |t|
    t.string   "question",   :default => "", :null => false
    t.text     "answer"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faqs_merchants", :force => true do |t|
    t.integer "faq_id"
    t.integer "merchant_id"
  end

  add_index "faqs_merchants", ["faq_id"], :name => "index_faqs_merchants_on_faq_id"
  add_index "faqs_merchants", ["merchant_id"], :name => "index_faqs_merchants_on_merchant_id"

  create_table "friends", :force => true do |t|
    t.string   "email",        :default => "", :null => false
    t.integer  "friend_of_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_lines", :force => true do |t|
    t.integer  "invoice_id"
    t.string   "uuid",               :limit => 32,                                :default => "", :null => false
    t.string   "description",                                                     :default => "", :null => false
    t.string   "origin",                                                          :default => "", :null => false
    t.decimal  "unit_amount_in_usd",               :precision => 10, :scale => 2
    t.integer  "quantity"
    t.decimal  "discount_in_usd",                  :precision => 10, :scale => 2
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "recurly_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subscription_id"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                                           :default => "", :null => false
    t.string   "status",                                         :default => "", :null => false
    t.decimal  "subtotal_in_usd", :precision => 10, :scale => 2
    t.decimal  "total_in_usd",    :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_number"
  end

  create_table "invoices_subscriptions", :force => true do |t|
    t.integer "invoice_id"
    t.integer "subscription_id"
  end

  create_table "marketing_best_sellers", :force => true do |t|
    t.integer  "plan_id"
    t.integer  "coupon_id"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "marketing_deal_sources", :force => true do |t|
    t.string   "url_code",   :default => "", :null => false
    t.string   "name",       :default => "", :null => false
    t.string   "image",      :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "marketing_deal_sources", ["url_code"], :name => "index_marketing_deal_sources_on_url_code"

  create_table "marketing_newsletters", :force => true do |t|
    t.string   "heading",                    :default => "",    :null => false
    t.string   "subheading",                 :default => "",    :null => false
    t.text     "main_content",               :default => "",    :null => false
    t.string   "main_image",                 :default => "",    :null => false
    t.string   "main_image_link",            :default => "",    :null => false
    t.integer  "plan_id"
    t.integer  "coupon_id"
    t.string   "the_value",                  :default => "",    :null => false
    t.string   "featured_price",             :default => "",    :null => false
    t.string   "featured_billing_cycle",     :default => "",    :null => false
    t.string   "footnote",                   :default => "",    :null => false
    t.string   "first_block_heading",        :default => "",    :null => false
    t.string   "first_block_link",           :default => "",    :null => false
    t.string   "first_block_image",          :default => "",    :null => false
    t.string   "first_block_description",    :default => "",    :null => false
    t.string   "second_block_heading",       :default => "",    :null => false
    t.string   "second_block_link",          :default => "",    :null => false
    t.string   "second_block_image",         :default => "",    :null => false
    t.string   "second_block_description",   :default => "",    :null => false
    t.string   "third_block_heading",        :default => "",    :null => false
    t.string   "third_block_link",           :default => "",    :null => false
    t.string   "third_block_image",          :default => "",    :null => false
    t.string   "third_block_description",    :default => "",    :null => false
    t.boolean  "show_getting_started_steps", :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject",                    :default => "",    :null => false
  end

  create_table "marketing_user_attachments", :force => true do |t|
    t.integer  "user_id"
    t.string   "image",           :default => "", :null => false
    t.string   "attachment_type", :default => "", :null => false
    t.string   "email",           :default => "", :null => false
    t.string   "name",            :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "marketing_user_attachments", ["user_id"], :name => "index_marketing_user_attachments_on_user_id"

  create_table "marketing_video_reviews", :force => true do |t|
    t.integer  "plan_id"
    t.string   "raw_url",     :default => "",    :null => false
    t.string   "title",       :default => "",    :null => false
    t.string   "author",      :default => "",    :null => false
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "thumbnail",   :default => "",    :null => false
    t.boolean  "is_featured", :default => false
  end

  add_index "marketing_video_reviews", ["plan_id"], :name => "index_marketing_video_reviews_on_plan_id"

  create_table "merchants", :force => true do |t|
    t.string   "business_name",                                                      :default => "",         :null => false
    t.string   "location",                                                           :default => "",         :null => false
    t.decimal  "lat"
    t.decimal  "lng"
    t.string   "image",                                                              :default => "",         :null => false
    t.string   "logo",                                                               :default => "",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "video_url",                                                          :default => "",         :null => false
    t.string   "video_thumbnail_url",                                                :default => "",         :null => false
    t.boolean  "is_active",                                                          :default => false
    t.string   "email",                                                              :default => "",         :null => false
    t.integer  "delivery_type",                                                      :default => 1,          :null => false
    t.string   "address1",                                                           :default => "",         :null => false
    t.string   "address2",                                                           :default => "",         :null => false
    t.string   "zipcode",                                                            :default => "",         :null => false
    t.string   "city",                                                               :default => "",         :null => false
    t.string   "country",                                                            :default => "",         :null => false
    t.string   "state",                                                              :default => "",         :null => false
    t.string   "phone",                                                              :default => "",         :null => false
    t.string   "contact_name",                                                       :default => "",         :null => false
    t.string   "contact_last_name",                                                  :default => "",         :null => false
    t.string   "website",                                                            :default => "",         :null => false
    t.string   "business_type",                                                      :default => "",         :null => false
    t.text     "comments"
    t.boolean  "show_location",                                                      :default => true
    t.string   "business_size",                                                      :default => "",         :null => false
    t.string   "management_config",                                                  :default => "",         :null => false
    t.string   "assistance_config",                                                  :default => "",         :null => false
    t.boolean  "marketplace"
    t.boolean  "custom_site"
    t.boolean  "point_of_sale"
    t.text     "about"
    t.string   "shipping_type",          :limit => 20,                               :default => "",         :null => false
    t.decimal  "shipping_rate",                        :precision => 7, :scale => 2
    t.decimal  "commission_rate"
    t.string   "marketing_phrase",                                                   :default => "",         :null => false
    t.text     "terms_of_service"
    t.string   "taxation_policy",                                                    :default => "no_taxes", :null => false
    t.string   "custom_site_url",                                                    :default => "",         :null => false
    t.string   "tagline",                                                            :default => "",         :null => false
    t.string   "facebook_url",                                                       :default => "",         :null => false
    t.string   "twitter_url",                                                        :default => "",         :null => false
    t.string   "custom_site_base_color", :limit => 6,                                :default => "",         :null => false
    t.string   "about_image",                                                        :default => "",         :null => false
    t.string   "storefront_logo",                                                    :default => "",         :null => false
    t.string   "storefront_heading",                                                 :default => "",         :null => false
    t.boolean  "is_prospect",                                                        :default => false
    t.integer  "first_installment"
    t.string   "custom_message_type",                                                :default => "",         :null => false
    t.integer  "cutoff_day",                                                         :default => 15,         :null => false
    t.integer  "max_delay",                                                          :default => 20,         :null => false
  end

  create_table "merchants_merchants", :force => true do |t|
    t.integer "merchant_id"
    t.integer "related_merchant_id"
  end

  create_table "merchants_states", :force => true do |t|
    t.integer "merchant_id"
    t.integer "state_id"
  end

  create_table "merchants_zipcodes", :force => true do |t|
    t.integer "merchant_id"
    t.integer "zipcode_id"
  end

  create_table "newsletter_subscribers", :force => true do |t|
    t.string   "email",           :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "related_user_id"
  end

  create_table "option_groups", :force => true do |t|
    t.integer "plan_id"
    t.string  "description",                  :default => "",    :null => false
    t.string  "option_type",    :limit => 20, :default => "",    :null => false
    t.boolean "allow_multiple"
    t.boolean "is_active",                    :default => false
    t.integer "order"
  end

  create_table "option_recurly_codes", :force => true do |t|
    t.integer "plan_recurrence_id"
    t.integer "option_id"
    t.string  "recurly_code",                     :default => "", :null => false
    t.string  "status",             :limit => 20, :default => "", :null => false
  end

  create_table "options", :force => true do |t|
    t.integer "option_group_id"
    t.string  "title",                                              :default => "",    :null => false
    t.text    "description"
    t.decimal "amount",              :precision => 10, :scale => 2
    t.string  "image",                                              :default => "",    :null => false
    t.integer "order"
    t.boolean "is_active",                                          :default => false
    t.string  "invoice_description",                                :default => "",    :null => false
  end

  create_table "plan_documents", :force => true do |t|
    t.integer "plan_id"
    t.string  "name",        :default => "", :null => false
    t.string  "description", :default => "", :null => false
    t.string  "file",        :default => "", :null => false
  end

  create_table "plan_recurrences", :force => true do |t|
    t.integer "plan_id"
    t.decimal "amount",                          :precision => 10, :scale => 2
    t.string  "status",            :limit => 20,                                :default => "",    :null => false
    t.string  "recurrence_type",   :limit => 40,                                :default => "",    :null => false
    t.string  "recurly_plan_code", :limit => 50,                                :default => "",    :null => false
    t.boolean "is_active",                                                      :default => false
    t.decimal "fake_amount",                     :precision => 10, :scale => 2
  end

  create_table "plan_subscription_archives", :force => true do |t|
    t.integer  "plan_id",                    :null => false
    t.string   "title",      :default => "", :null => false
    t.date     "sent_on",                    :null => false
    t.string   "image",      :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.string   "name",                                    :default => "",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "marketing_phrase",                        :default => "",        :null => false
    t.string   "thumbnail",                               :default => "",        :null => false
    t.string   "icon",                                    :default => "",        :null => false
    t.integer  "merchant_id"
    t.string   "status",                                  :default => "pending", :null => false
    t.string   "unique_hash",                             :default => "",        :null => false
    t.integer  "initial_count",                           :default => 0,         :null => false
    t.text     "description"
    t.text     "details"
    t.text     "shipping_info"
    t.string   "plan_type",                 :limit => 40, :default => "",        :null => false
    t.text     "terms"
    t.text     "fine_print"
    t.boolean  "extra_notes"
    t.string   "short_description",                       :default => "",        :null => false
    t.string   "notes_to_customer",                       :default => "",        :null => false
    t.string   "merchant_storefront_image",               :default => "",        :null => false
    t.boolean  "is_featured",                             :default => false
    t.string   "buying_aid",                              :default => "",        :null => false
    t.string   "slug",                                    :default => "",        :null => false
    t.integer  "featured_coupon_id"
    t.date     "activated_at"
  end

  create_table "plans_tags", :force => true do |t|
    t.integer "plan_id"
    t.integer "tag_id"
  end

  create_table "queue_classic_jobs", :force => true do |t|
    t.string   "q_name"
    t.string   "method"
    t.text     "args"
    t.datetime "locked_at"
  end

  add_index "queue_classic_jobs", ["id"], :name => "index_queue_classic_jobs_on_id"

  create_table "redemptions", :force => true do |t|
    t.integer  "coupon_id"
    t.integer  "user_id"
    t.boolean  "is_redeemed",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "customer_service", :default => false, :null => false
  end

  create_table "registry", :force => true do |t|
    t.string   "key",        :default => "", :null => false
    t.string   "value",      :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipments", :force => true do |t|
    t.integer  "subscription_id"
    t.string   "tracking_number", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "carrier",         :default => "", :null => false
  end

  create_table "shipping_infos", :force => true do |t|
    t.boolean  "is_default"
    t.integer  "user_id"
    t.string   "first_name",            :default => "",    :null => false
    t.string   "last_name",             :default => "",    :null => false
    t.string   "address1",              :default => "",    :null => false
    t.string   "address2",              :default => "",    :null => false
    t.string   "zipcode_str",           :default => "",    :null => false
    t.string   "phone",                 :default => "",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "zipcode_id"
    t.string   "delivery_instructions", :default => "",    :null => false
    t.string   "city",                  :default => "",    :null => false
    t.boolean  "is_active",             :default => false, :null => false
  end

  create_table "shipping_prices", :force => true do |t|
    t.integer  "merchant_id"
    t.decimal  "percentage"
    t.decimal  "amount_in_cents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state_id"
  end

  create_table "states", :force => true do |t|
    t.string "code", :default => "", :null => false
    t.string "name", :default => "", :null => false
  end

  create_table "subscription_editions", :force => true do |t|
    t.integer  "subscription_id",   :null => false
    t.text     "attributes_data"
    t.text     "pricing_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "next_renewal_date"
  end

  create_table "subscription_options", :force => true do |t|
    t.integer "subscription_id"
    t.integer "option_id"
    t.decimal "unit_amount",     :precision => 10, :scale => 2
    t.integer "quantity",                                       :default => 1, :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "current_period_ends_at"
    t.string   "state",                                                       :default => "inactive", :null => false
    t.string   "recurly_code",                                                :default => "",         :null => false
    t.integer  "plan_recurrence_id"
    t.integer  "shipping_info_id"
    t.decimal  "base_amount",                  :precision => 10, :scale => 2, :default => 0.0,        :null => false
    t.float    "shipping_amount"
    t.string   "shipping_type",                                               :default => "",         :null => false
    t.text     "user_note"
    t.string   "recurly_coupon_code",                                         :default => "",         :null => false
    t.date     "first_shipping_date"
    t.integer  "redemption_id"
    t.date     "next_shipping_date"
    t.string   "shipping_status",                                             :default => "active",   :null => false
    t.datetime "canceled_at"
    t.decimal  "recurrent_total",              :precision => 10, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "onetime_total",                :precision => 10, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "first_time_total",             :precision => 10, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "onetime_tax_amount",           :precision => 10, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "recurrent_tax_amount",         :precision => 10, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "first_time_discount",          :precision => 10, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "recurrent_discount",           :precision => 10, :scale => 2, :default => 0.0,        :null => false
    t.boolean  "is_gift",                                                     :default => false,      :null => false
    t.text     "gift_description"
    t.string   "giftee_email",                                                :default => "",         :null => false
    t.boolean  "notify_giftee_on_email",                                      :default => false,      :null => false
    t.string   "cc_last_four",                                                :default => "",         :null => false
    t.string   "cc_type",                                                     :default => "",         :null => false
    t.string   "cc_exp_date",                                                 :default => "",         :null => false
    t.boolean  "is_past_due",                                                 :default => false,      :null => false
    t.datetime "expired_at"
    t.string   "giftee_name",                                                 :default => "",         :null => false
    t.boolean  "notify_giftee_on_shipment",                                   :default => false,      :null => false
    t.datetime "current_period_started_at"
    t.string   "last_successful_payment",                                     :default => "",         :null => false
    t.date     "last_successful_payment_date"
    t.date     "period_start_date"
    t.datetime "last_payment_date"
    t.decimal  "last_payment_amount",          :precision => 10, :scale => 2
  end

  add_index "subscriptions", ["recurly_code"], :name => "index_subscriptions_on_recurly_code"

  create_table "superhub_plan_groups", :force => true do |t|
    t.string   "superhub",   :limit => 50,  :default => "", :null => false
    t.string   "title",      :limit => 200, :default => "", :null => false
    t.string   "subtitle",                  :default => "", :null => false
    t.string   "group_type",                :default => "", :null => false
    t.integer  "ordering",                  :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label",                     :default => "", :null => false
  end

  create_table "superhub_plans", :force => true do |t|
    t.integer  "plan_id"
    t.integer  "superhub_plan_group_id"
    t.integer  "ordering",               :default => 0,  :null => false
    t.string   "image",                  :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                  :default => "", :null => false
    t.string   "subtitle",               :default => "", :null => false
    t.string   "video_url",              :default => "", :null => false
  end

  create_table "tag_highlights", :force => true do |t|
    t.integer  "tag_id"
    t.string   "image",            :default => "",    :null => false
    t.string   "title",            :default => "",    :null => false
    t.string   "highlight_type",   :default => "",    :null => false
    t.integer  "plan_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price_amount"
    t.string   "price_recurrence", :default => "",    :null => false
    t.integer  "ordering",         :default => 0
    t.boolean  "on_sale",          :default => false
    t.boolean  "is_active",        :default => true,  :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "keyword",      :default => "", :null => false
    t.boolean  "is_featured"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "header_image", :default => "", :null => false
    t.string   "slug",         :default => "", :null => false
    t.integer  "order"
  end

  create_table "tax_rates", :force => true do |t|
    t.integer  "merchant_id"
    t.integer  "state_id"
    t.decimal  "percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "invoice_id"
    t.string   "recurly_code", :default => "", :null => false
    t.string   "action",       :default => "", :null => false
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_preferences", :force => true do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.integer  "zipcode_id"
    t.string   "status",      :default => "", :null => false
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.string   "company_name"
    t.string   "zipcode_str"
    t.integer  "roles"
    t.string   "recurly_code",                          :default => "",    :null => false
    t.boolean  "is_active",                             :default => false
    t.integer  "zipcode_id"
    t.integer  "merchant_id"
    t.string   "full_name"
    t.string   "address",                               :default => "",    :null => false
    t.string   "city",                                  :default => "",    :null => false
    t.string   "state_id",                              :default => "",    :null => false
    t.boolean  "is_test",                               :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["recurly_code"], :name => "index_users_on_recurly_code"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "zipcodes", :force => true do |t|
    t.string  "number",  :default => "", :null => false
    t.integer "city_id"
  end

end
