class NotificationMailer < ActionMailer::Base

  default from: 'info@monthlys.com'
  ADMIN_TEAM = 'orders@monthlys.com'
  SUPPORT_TEAM = 'support@monthlys.com'
  OPERATIONS_TEAM = 'jillian@monthlys.com, mark@monthlys.com, vero@monthlys.com'
  MERCHANT_SUPPORT_TEAM = 'merchant.support@monthlys.com'
  MARKETING_TEAM = 'frank@monthlys.com, lou@monthlys.com, carolyn@monthlys.com, vero@monthlys.com'

  def send_welcome_email(user_id)
    @user = User.find(user_id)
    @zipcode = @user.zipcode_str
    @city = Zipcode.find_by_number(@zipcode).try(:city)

    @plans = if @city
      Plan
        .available_in_city(@city)
        .with_featured_categories
        .has_status(:active)
        .limit(4)
    else
      []
    end
    @plan = @plans.first if @plans.one?

    mail(to: @user.email, subject: 'Welcome to Monthlys!')
  end

  def send_merchant_subscription_email(subscription_id, action)
    @subscription = Subscription.find(subscription_id)
    @shipping_info = @subscription.shipping_info
    @merchant = @subscription.merchant
    @user = @subscription.user

    @action = action.to_sym

    @title = {
      new: "#{@subscription.user.email} has just subscribed to #{@subscription.plan.name} in monthlys.com",
      cancel: "#{@subscription.user.email} has just canceled his subscription to #{@subscription.plan.name} in monthlys.com",
      reactivate: "#{@subscription.user.email} has just reactivated his subscription to #{@subscription.plan.name} in monthlys.com",
      change: "#{@subscription.user.email} has just changed his #{@subscription.plan.name} subscription in monthlys.com"
    }[@action]

    mail({
      to: ADMIN_TEAM,
      subject: @title
    })
  end

  def send_merchant_welcome_email(merchant_id)
    @merchant = Merchant.find(merchant_id)
    mail(from: MERCHANT_SUPPORT_TEAM, to: @merchant.email, subject: "Congrats #{@merchant.name}! Thanks for joining Monthlys")
  end

  def send_subscription_reactivation_email(subscription_id)
    @subscription = Subscription.find(subscription_id)
    @user = @subscription.user
    mail({
      from: SUPPORT_TEAM,
      to: @user.email,
      subject: "Your subscription has been reactivated"
    });
  end

  # We are not sending activation emails until the MP is ready
  # def send_activation_email(merchant_id)
  #   @merchant = Merchant.find(merchant_id)
  #   mail(to: @merchant.email, subject: "Congrats #{@merchant.name}! Your monthlys' account has been activated")
  # end

  def send_contact_email(form_data)
    @name = form_data["name"]
    @email = form_data["email"]
    @content = form_data["content"]
    @merchant = Merchant.find(form_data["merchant_id"]) if form_data["merchant_id"]
    if @merchant
      mail(to: SUPPORT_TEAM, subject: "Contact form submission from Monthlys to #{@merchant.business_name} - #{@email}")
    else
      mail(to: SUPPORT_TEAM, subject: "Contact form submission from Monthlys - #{@email}")
    end
  end

  def send_merchant_account_application_email(merchant_id)
    @merchant = Merchant.find(merchant_id)
    mail(to: MARKETING_TEAM, subject: "New merchant account application")
  end

  def send_merchant_shipping_info_changed(old_shipping_info_desc, new_shipping_info_desc, subscriptions_id, user_id)
    @old_shipping_info_desc = old_shipping_info_desc
    @new_shipping_info_desc = new_shipping_info_desc
    @subscriptions = Subscription.where(id: subscriptions_id).all
    @user = User.find(user_id)
    mail(to: ADMIN_TEAM, subject: 'Shipping info changed for a user you have')
  end

  def send_giftee_subscription_email(subscription_id)
    @subscription = Subscription.find(subscription_id)
    @plan = @subscription.plan
    mail(to: @subscription.giftee_email, subject: "You got a gift subscription for #{@plan.name}!")
  end

  def send_user_refund_email(refund_id)
    @refund = Transaction.find(refund_id)
    @invoice = @refund.invoice
    @plan = @refund.associated_plan
    @user = @refund.user
    mail(to: @user.email, subject: 'You have a refund from Monthlys')
  end
end
