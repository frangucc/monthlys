class RegistrationsController < Devise::RegistrationsController

  authorize_resource class: false

  before_filter :force_ssl_with_params, only: [ :edit, :update ]
  before_filter :verify_registration_routes_constraint, only: [ :new_with_coupon ]
  before_filter :load_coupon_config, only: [ :new_with_coupon, :create_with_coupon ]

  def create
    create_registration(:new)
  end

  def new_with_coupon
    resource = build_resource({})
  end

  def create_with_coupon
    create_registration(:new_with_coupon) do
      coupon = Coupon.find_by_coupon_code(@coupon_config[:coupon_code])
      redemption = resource.redemptions.create!(coupon: coupon)
      Resque.enqueue(MarketingEmailsJob, @coupon_config[:et_mail_name], resource.id)
      # Overriding flash success
      flash[:success] = 'You successfully registered! You now got a new coupon available!'
      session[:redirect_to] = coupons_url
    end
  end

  def inactivate
    current_user.inactivate
    sign_out(current_user)
    redirect_to(root_path, flash: { success: 'Your account was successfully disabled. All your subscriptions were canceled and will expire on the next renewal date.' })
  end

  def form
    build_resource
    render partial: 'registrations_frame'
  end

private
  def create_registration(new_action)
    build_resource
    resource.zipcode_str = (params[:user] && params[:user][:zipcode_str])
    resource.is_active = true

    if resource.save
      Monthly::Rapi::Accounts.sync(resource)

      # Adding email recipient to ET and sending welcome emails
      resource.schedule_email_recipient_update
      Resque.enqueue(WelcomeEmailJob, resource.id)
      Resque.enqueue(MarketingEmailsJob, 'new_user_set_preferences', resource.id)
      Resque.enqueue(MarketingEmailsJob, 'coupon_invite_5_friends', resource.id)

      yield if block_given?

      sign_in(resource_name, resource)

      respond_to do |format|
        format.json do
          render(json: { status: :success, redirect: after_sign_up_path_for(resource) })
        end
        format.html do
          redirect_to after_sign_up_path_for(resource)
        end
      end
    else
      clean_up_passwords(resource)
      respond_to do |format|
        format.json do
          render json: { status: :error, errors: resource.errors.full_messages }
        end
        format.html do
          render new_action
        end
      end
    end
  end

  def load_coupon_config
    @coupon_name = params[:coupon_name].to_sym
    @coupon_config = Monthly::Application.config.app_config.register_coupons[@coupon_name]
  end

  def verify_registration_routes_constraint
    redirect_to root_url unless RegisterCouponsConstraint.new.matches?(request)
  end
end
