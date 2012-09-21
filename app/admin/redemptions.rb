ActiveAdmin.register Redemption do

  actions :index, :show, :new, :create
  menu :parent => "Marketing", label: "Coupons' Redemptions"

  scope :automatic_redemptions
  scope :customer_service

  index do
    column :id
    column :created_at
    column :coupon
    column :user
    column :is_redeemed
    default_actions
  end

  sidebar :about_redemptions, only: :index do
    ul do
      li "Redemptions are associations between coupons and users."
      li "By creating a redemption you'll enable a coupon for just a specific user. "
      li "The coupon will then be available on the user's coupon listing."
    end
  end

  form do |f|
    f.inputs do
      f.input :coupon, as: :select, collection: Coupon.active.not_available_to_all_users.order("coupon_code ASC").all, include_blank: false
      f.input :user, as: :select, collection: User.active.by_email, include_blank: false, member_label: :email
      f.input :customer_service, default: true
    end
    f.buttons
  end
end
