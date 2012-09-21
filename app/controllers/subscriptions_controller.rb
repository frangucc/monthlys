class SubscriptionsController < ApplicationController

  include PricesHelper

  load_and_authorize_resource
  skip_load_resource only: %w(index canceled expired new create)

  before_filter :ensure_subscription_is_active, only: %w(confirm_destroy destroy)
  before_filter :ensure_subscription_is_not_expired, only: %w(edit update)
  before_filter :ensure_subscription_is_canceled, only: %w(confirm_reactivate reactivate)

  def index
    @active_subscriptions = current_user.subscriptions.has_state(:active)
    @canceled_subscriptions = current_user.subscriptions.has_state(:canceled)
    @expired_subscriptions = current_user.subscriptions.has_state(:expired)
  end

  def show
  end

  def new
    @previous_subscription = current_user.subscriptions.find(params[:previous_subscription_id])
    @subscription = current_user.subscriptions.new

    @plan = @previous_subscription.plan

    return redirect_to subscriptions_path, flash: { error: 'You\'re already subscribed to this plan.' } if current_user.is_subscribed?(@plan)

    @plan_recurrences = @plan.active_plan_recurrences
    @option_groups = @plan.active_option_groups
    @shipping_infos = current_user.shipping_infos.active.all
    @plan_recurrence = @plan_recurrences.find {|pr| pr.id == @subscription.plan_recurrence_id } || @plan_recurrences.first
  end

  def create
    respond_to do |format|
      format.json do
        previous_subscription = current_user.subscriptions.find(params[:previous_subscription_id])
        plan = previous_subscription.plan

        subscription_relations = {
          user: current_user,
          plan: plan,
          plan_recurrence: plan.plan_recurrences.find(subscription_params[:plan_recurrence_id]),
          shipping_info: current_user.shipping_infos.active.find_by_id(subscription_params[:shipping_info_id]),
          options: plan.options.active.where(id: subscription_params[:options_id]).includes(:option_group).all,
          coupon: nil
        }

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
          render json: { status: :success, redirect_to: ms_path(thank_you_subscription_path(subscription)) }
        else
          notify_airbrake("Logged action: #{validator.errors.join(', ')}")
          render json: { status: :error, errors: validator.errors }
        end
      end
    end
  rescue Recurly::Transaction::DeclinedError, Recurly::Transaction::RetryableError => e
    redirect_to subscriptions_path, flash: { error: e.message }
  end

  def edit
    @plan = @subscription.plan
    @plan_recurrences = @plan.active_plan_recurrences
    @option_groups = @plan.active_option_groups.reject(&:onetime?)
    @shipping_infos = current_user.shipping_infos.active.all
    @plan_recurrence = @subscription.plan_recurrence.is_active? ? @subscription.plan_recurrence : @plan_recurrences.first
  end

  def update
    respond_to do |format|
      format.json do
        plan_recurrence = PlanRecurrence.find(subscription_params[:plan_recurrence_id])
        plan = plan_recurrence.plan

        subscription_relations = {
          user: current_user,
          plan: plan,
          plan_recurrence: plan_recurrence,
          shipping_info: current_user.shipping_infos.active.find_by_id(subscription_params[:shipping_info_id]),
          options: plan.options.active.where(id: subscription_params[:options_id]).includes(:option_group).all,
          coupon: nil
        }

        validator = SubscriptionsValidator.new(subscription_relations, @subscription)
        if validator.valid?
          Monthly::Rapi::Subscriptions.reactivate(@subscription) if @subscription.canceled?
          Monthly::Rapi::Subscriptions.update(@subscription, subscription_relations)
          Resque.enqueue(MerchantSubscriptionJob, @subscription.id, :change)
          flash[:success] = 'Subscription updated successfully!'
          render json: { status: :success, redirect_to: subscription_path(@subscription) }
        else
          render json: { status: :error, errors: validator.errors }
        end
      end
    end
  end

  def totals
    respond_to do |format|
      format.json do
        plan_recurrence = PlanRecurrence.find(subscription_params[:plan_recurrence_id])
        plan = plan_recurrence.plan
        shipping_info = (plan.shippable? && current_user.shipping_infos.active.find_by_id(subscription_params[:shipping_info_id])) || nil
        options = plan.options.where(id: subscription_params[:options_id]).includes(:option_group).all

        totals_pricing = SubscriptionManager::TotalsPricing.totals({
          user: current_user,
          plan_recurrence: plan_recurrence,
          options: options,
          shipping_info: shipping_info
        })

        refresh_options = plan.options.active.map do |option|
          { id: option.id, billing_desc: (option.amount.zero?)? 'No additional charge' : "Add $ #{pretty_price(option.amount_per_billing(plan_recurrence))} #{plan_recurrence.billing_desc}" }
        end

        render json: {
          totals: {
            recurrent_without_extras: pretty_price(totals_pricing[:recurrent_without_extras]),
            recurrent_shipping: totals_pricing[:recurrent_shipping] ? pretty_price(totals_pricing[:recurrent_shipping]) : nil,
            recurrent_tax: totals_pricing[:recurrent_tax] ? pretty_price(totals_pricing[:recurrent_tax]) : nil,
            recurrent_total: pretty_price(totals_pricing[:recurrent_total])
          },
          billing_desc: plan_recurrence.billing_recurrence_in_words.capitalize,
          refresh_options: refresh_options
        }
      end
    end
  end

  def thank_you
    load_sidebar_categories
    @invoice = @subscription.invoices.last
  end

  def confirm_destroy
  end

  def destroy
    Monthly::Rapi::Subscriptions.cancel(@subscription)
    # Notify the admins about the subscription cancellation
    Resque.enqueue(MerchantSubscriptionJob, @subscription.id, :cancel)
    redirect_to ms_path(subscriptions_path), flash: { success: 'Subscription canceled successfully' }
  end

  def confirm_reactivate
    @billing_info = Monthly::Rapi::Accounts.billing_info(current_user)
    @plan_recurrence = @subscription.plan_recurrence
    @plan = @plan_recurrence.plan
  end

  def reactivate
    Monthly::Rapi::Subscriptions.reactivate(@subscription)
    # Notify the admins about the subscription reactivation
    Resque.enqueue(MerchantSubscriptionJob, @subscription.id, :reactivate)
    redirect_to ms_path(subscriptions_path), flash: { success: 'Subscription reactivated successfully.' }
  end

private
  def subscription_params
    (params[:subscription] || {}).slice(:plan_recurrence_id, :options_id, :shipping_info_id)
  end

  def ensure_subscription_is_active
    redirect_to(ms_path(subscription_path(@subscription)), flash: { error: 'This subscription is not active' }) unless @subscription.active?
  end

  def ensure_subscription_is_not_expired
    redirect_to(ms_path(subscription_path(@subscription)), flash: { error: 'This subscription is expired' }) if @subscription.expired?
  end

  def ensure_subscription_is_canceled
    redirect_to(ms_path(subscription_path(@subscription)), flash: { error: 'This subscription is not canceled' }) unless @subscription.canceled?
  end
end
