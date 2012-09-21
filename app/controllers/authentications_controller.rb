class AuthenticationsController < ApplicationController

  load_and_authorize_resource
  skip_load_resource only: [ :index, :create, :failure ]

  def index
    @authentications = current_user.authentications
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    create_coupon = !! params[:state]
    if authentication
      if current_user
        flash[:notice] = 'This #{authentication.provider} account has already been taken. Please sign out from #{authentication.provider} and sign in as yourself.'
        redirect_to new_user_registration_url
      else
        # If authentication exists, sign the user in
        flash[:success] = 'Signed in successfully.'
        sign_in_and_redirect(:user, authentication.user)
      end
    elsif current_user
      # If the user is logged in, add the authentication to that user
      current_user.authentications.create!(provider: omniauth['provider'], uid: omniauth['uid'])
      flash[:success] = "Authentication added successfuly."
      redirect_to authentications_url
    else
      # Otherwise create a new user, and add the authentication to it
      user = apply_omniauth(omniauth)
      user.is_active = true
      if user.save
        send_marketing_notifications_to_user(user, create_coupon)
        flash[:success] = 'Signed in successfully.'
        sign_in_and_redirect(:user, user)
      else
        # This should never happen
        flash[:error] = user.errors.full_messages
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end

  def destroy
    @authentication.destroy
    flash[:notice] = 'Successfully destroyed authentication.'
    redirect_to authentications_url
  end

  def failure
    redirect_to new_user_registration_path, flash: { notice: 'There has been an error using this authentication method. Please try again later.' }
  end

private
  def apply_omniauth(omniauth)
    email = omniauth['info']['email']
    user = User.find_by_email(email) || User.new(email: email, zipcode_str: '60654') # FIXME
    user.authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
    user
  end

  def send_marketing_notifications_to_user(user, create_coupon = false)
    Monthly::Rapi::Accounts.sync(user)

    # Adding email recipient to ET and sending welcome emails
    user.schedule_email_recipient_update
    Resque.enqueue(WelcomeEmailJob, user.id)
    Resque.enqueue(MarketingEmailsJob, 'new_user_set_preferences', user.id)

    if create_coupon
      coupon_config = Monthly::Application.config.app_config.register_coupons[params[:state].to_sym]
      coupon = Coupon.find_by_coupon_code(coupon_config[:coupon_code])
      redemption = user.redemptions.create!(coupon: coupon)
      Resque.enqueue(MarketingEmailsJob, coupon_config[:et_mail_name], user.id)
      # Overriding flash success
      flash[:success] = 'You successfully registered! You now got a new coupon available!'
      session[:redirect_to] = coupons_url
    else
      Resque.enqueue(MarketingEmailsJob, 'coupon_invite_5_friends', user.id)
    end
  end
end
