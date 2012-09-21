class PlanConfiguratorsController < ApplicationController
  include PricesHelper

  load_and_authorize_resource class: false

  load_and_authorize_resource :plan, find_by: :slug
  load_resource :merchant, through: :plan, singleton: true

  before_filter :force_ssl_with_params, except: %w(zipcode_confirmation zipcode_confirmation_submit display_totals)
  before_filter :validate_configurator_params, only: [ :checkout ]
  before_filter :load_configurator_resources, only: [ :checkout, :confirmation ]
  before_filter :validate_not_subscribed_already, except: %w(zipcode_confirmation zipcode_confirmation_submit display_totals)
  before_filter :validate_plan_status, except: [ :display_totals ]

  def checkout
    if user_signed_in?
      @has_subscriptions = current_user.subscriptions.any?
      @is_shippable = @plan.shippable?
      @has_billing_info = !! current_user.billing_info
      if params[:subscription] && params[:subscription].is_a?(Hash)
        @coupon = Coupon.find_by_coupon_code(params[:subscription][:coupon_code])
        @deal_source = Marketing::DealSource.find_by_url_code(params[:subscription][:source])
      end
    else
      @has_subscriptions = false
      @is_shippable = false
      @has_billing_info = true
      @coupon = nil
    end
  end

  def submit
    validator = SubscriptionsValidator.new(subscription_relations)

    if validator.valid?
      subscription = Monthly::Rapi::Subscriptions.create(subscription_relations.merge({
        is_gift: subscription_params[:is_gift] == '1',
        notify_giftee_on_email: subscription_params[:notify_giftee_on_email] == '1',
        notify_giftee_on_shipment: subscription_params[:notify_giftee_on_shipment] == '1',
        giftee_name: subscription_params[:giftee_name],
        giftee_email: subscription_params[:giftee_email],
        gift_description: subscription_params[:gift_description]
      }))
      if subscription.is_gift? && subscription.notify_giftee_on_email? &&
        Monthly::Application.config.app_config.email_validation_regex =~ subscription.giftee_email

        Resque.enqueue(GifteeSubscriptionJob, subscription.id)
      end
      # Notify the admins about the new subscription
      Resque.enqueue(MerchantSubscriptionJob, subscription.id, :new)
      # Send to the subscription detail with the 'Thank you' message (subscribed_to parameter)
      redirect_to ms_path(thank_you_subscription_path(subscription))
    else
      notify_airbrake("Logged action: #{validator.errors.join(', ')}")
      redirect_to ms_path(checkout_plan_configurator_path(subscription_relations[:plan], subscription: {
        plan_recurrence_id: subscription_relations[:plan_recurrence].try(:id),
        options_id: subscription_relations[:options].map(&:id),
        coupon_code: subscription_relations[:coupon].try(:coupon_code)
      })), flash: { error: validator.errors }
    end
  rescue Recurly::Transaction::DeclinedError, Recurly::Transaction::RetryableError => e
    redirect_to subscriptions_path, flash: { error: e.message }
  end

  def submit_shipping_info
    errors = {}
    if update_user?
      merchant = @merchant if copy_shipping?
      user_errors = validate_address(params[:personal_info], merchant)
      errors[:personal_info] = user_errors unless user_errors.nil?
    end
    if create_shipping? && !copy_shipping?
      shipping_errors = validate_address(params[:shipping_info], @merchant)
      errors[:shipping_info] = shipping_errors unless shipping_errors.nil?
    end
    coupon_id = nil
    if has_coupon?
      coupon = Coupon.find_by_coupon_code(params[:coupon][:coupon_code])
      if coupon && (coupon.available_to_all_plans? || coupon.plans.include?(@plan)) && current_user.available_coupon?(coupon)
        coupon_id = coupon.id
      else
        errors[:coupon] = ['Invalid Coupon Code']
      end
    end

    if errors.empty?
      update_personal_info if update_user?

      shipping_info = create_or_update_shipping_info

      render json: { status: :success, shipping_info_id: shipping_info.try(:id), coupon_id: coupon_id }
    else
      render json: { status: :error, errors: errors }
    end
  end

  def confirmation
    respond_to do |format|
      format.js
    end
  end

  def coupon_valid
    if (coupon = Coupon.find_by_coupon_code(params[:coupon][:coupon_code].to_s.strip)) &&
      current_user.available_coupon?(coupon) &&
      (coupon.available_to_all_plans? || coupon.plans.include?(@plan))

      render json: { status: :success, coupon_id: coupon.id, message: 'Coupon redeemed!' }
    else
      render json: { status: :error, errors: ['Invalid coupon code'] }
    end
  end

  def zipcode_confirmation
    @user = (user_signed_in? && current_user) || User.new
  end

  def zipcode_confirmation_submit
    @user = (user_signed_in? && current_user) || User.new
    zipcode = Zipcode.find_or_create_by_number(params_zipcode_filter[:zipcode_str])
    if @merchant.supports_zipcode?(zipcode)
      if user_signed_in?
        @user.update_attributes(params_zipcode_filter)
      else
        geocoder_service.set_zipcode(zipcode)
      end
      render json: { status: :success }
    else
      UserPreferencesService.new(current_user).set_zipcode(zipcode).plan_out_of_area(@plan) if user_signed_in?
      render json: { status: :error, message: "We do not deliver to this zipcode, wanna try <a href='/'>other plans</a>?".html_safe }
    end
  end

  def display_totals
    plan_recurrence = @plan.plan_recurrences.find_by_id(params[:plan_recurrence_id])
    options = @plan.options.active.where(id: params[:options_id])
    coupon = Coupon.find_by_coupon_code(params[:coupon_code])

    return head(:bad_request) if !plan_recurrence

    totals_pricing = SubscriptionManager::TotalsPricing.totals({
      plan_recurrence: plan_recurrence,
      options: options,
      coupon: coupon
    })

    refresh_options = @plan.options.active.map do |option|
      { id: option.id, billing_desc: (option.amount.zero?)? 'No additional charge' : "Add $ #{pretty_price(option.amount_per_billing(plan_recurrence))} #{plan_recurrence.billing_desc}" }
    end

    json_response = {
      recurrent_total: pretty_price(totals_pricing[:recurrent_without_extras]),
      first_time_total: pretty_price(totals_pricing[:first_time_without_extras]),
      billing_desc: plan_recurrence.billing_desc,
      refresh_options: refresh_options
    }

    json_response[:old_price] = "$#{sprintf('%.02f', plan_recurrence.fake_amount)}" if plan_recurrence.fake_amount

    render json: json_response
  end

private
  def subscription_params
    (params[:subscription] || {}).slice(:plan_recurrence_id, :shipping_info_id, :options_id, :is_gift, :notify_giftee_on_email, :notify_giftee_on_shipment, :gift_description, :giftee_name, :giftee_email, :coupon_id)
  end

  def subscription_coupon
    if (coupon = Coupon.find_by_id(subscription_params[:coupon_id]))
      coupon if current_user.available_coupon?(coupon)
    end
  end

  def load_configurator_resources
    @plan_recurrence = subscription_relations[:plan_recurrence]
    @options = subscription_relations[:options]
    @is_gift = !!subscription_params[:is_gift]

    @shipping_infos = user_signed_in? ? current_user.shipping_infos.active : []

    if user_signed_in? && @plan.shippable?
      if !subscription_params[:shipping_info_id].blank?
        @shipping_info = @shipping_infos.find_by_id(subscription_params[:shipping_info_id])
      elsif !params[:zipcode_str].blank?
        zipcode = Zipcode.find_or_create_by_number(params[:zipcode_str])
        @shipping_info = ShippingInfo.new(zipcode_str: params[:zipcode_str], zipcode: zipcode) if zipcode.valid?
      else
        @shipping_info = @shipping_infos.find do |si|
          @merchant.supports_zipcode?(si.zipcode)
        end
      end
      @shipping_info ||= ShippingInfo.new
    end

    @coupon = subscription_coupon if subscription_coupon

    @totals_pricing = SubscriptionManager::TotalsPricing.totals({
      user: current_user,
      plan_recurrence: @plan_recurrence,
      options: @options,
      coupon: @coupon,
      shipping_info: @shipping_info
    })
  end

  def subscription_relations
    unless @subscription_relations
      plan_recurrence = PlanRecurrence.find_by_id(subscription_params[:plan_recurrence_id])
      coupon = subscription_params[:coupon_id] && Coupon.find_by_id(subscription_params[:coupon_id])
      @subscription_relations = {
        user: current_user,
        plan_recurrence: plan_recurrence,
        plan: plan_recurrence.plan,
        shipping_info: (user_signed_in? && current_user.shipping_infos.active.find_by_id(subscription_params[:shipping_info_id])) || nil,
        options: Option.where(id: subscription_params[:options_id]).includes(:option_group).all,
        coupon: (coupon && current_user.available_coupon?(coupon)) ? coupon : nil
      }
    end
    @subscription_relations
  end

  def params_zipcode_filter
    params[:user].slice(:zipcode_str)
  end

  def validate_not_subscribed_already
    if user_signed_in? && current_user.subscriptions.has_state(:active, :canceled).includes(plan_recurrence: :plan).where(plan_recurrences: { plan_id: @plan.id }).any?
      redirect_to ms_path(plan_path(@plan)), flash: { error: 'You are already subscribed to this plan.' }
    end
  end

  def validate_configurator_params
    if @plan.pending? || @plan.discarded?
      not_found
    elsif !@plan.plan_recurrences.find_by_id(subscription_params[:plan_recurrence_id])
      redirect_to ms_path(plan_path(@plan)), flash: { error: 'Please choose the frequency and options you want first.' }
    end
  end

  def validate_plan_status
    unless @plan.active?
      redirect_url = @plan.pending? ? ms_path(preview_plan_path(@plan.unique_hash)) : ms_path(plan_path(@plan))
      redirect_to redirect_url, flash: { error: "This plan is #{@plan.status}. You cannot subscribe to it." }
    end
  end

  def validate_address(address_attributes, merchant = nil)
    validator = AddressValidator.new(address_attributes, merchant: merchant)

    if merchant
      UserPreferencesService.new(current_user).plan_out_of_area(@plan)
    end
    validator.errors unless validator.valid?
  end

  def update_user?
    params[:personal_info]
  end

  def create_shipping?
    params[:shipping_info] && !copy_shipping?
  end

  def copy_shipping?
    !! params[:copy_shipping_info]
  end

  def has_coupon?
    params[:coupon] && !params[:coupon][:coupon_code].blank?
  end

  def create_or_update_shipping_info
    return unless create_shipping? || copy_shipping?

    shipping_info_attrs = (create_shipping?) ? params[:shipping_info] : params[:personal_info]
    id = params[:shipping_info]['id']
    shipping_info = nil

    if id.blank? # Creating
      shipping_info_attrs.merge!(is_default: true, is_active: true)
      shipping_info = current_user.shipping_infos.create!(shipping_info_attrs)
    else # Updating
      shipping_info = current_user.shipping_infos.find(id)
      shipping_info.update_attributes(shipping_info_attrs)
    end
    shipping_info
  end

  def update_personal_info
    p = params[:personal_info]
    current_user.update_attributes!({
      full_name: "#{p['first_name']} #{p['last_name']}",
      address: p['address'],
      zipcode_str: p['zipcode_str'],
      city: p['city'],
      state: p['state'],
      phone: p['phone']
    })
    current_user
  end
end
