class SubscriptionsValidator

  attr_reader :errors

  class << self
    def valid?(subscription_attributes)
      self.new(subscription_attributes).valid?
    end

    def valid_update?(subscription, subscription_attributes)
      self.new(subscription_attributes, subscription).valid?
    end
  end

  def initialize(subscription_attributes, subscription = nil)
    @subscription_attributes = subscription_attributes
    @subscription = subscription
    @errors = []
  end

  def valid?
    if @subscription && @subscription.persisted? # Update validations
      @errors << 'This recurrence does not belong to the previous plan.' unless same_plan_as_before?
      @errors << 'This recurrence is no longer valid.' unless active_plan_recurrence? # TODO: what happens when the PR is no longer active and the user wants to change his subscription?
      @errors << 'This merchant does not support your shipping location.' unless merchant_supports_zipcode?
      @errors << 'This user is not active.' unless user_is_active?
      @errors << 'Selected options are not valid.' unless options_are_valid? # TODO: Same as before, what happens when the option/option_group is no longer active and the user wants to change his subscription?
      @errors << 'You did not change any field.' unless changed_at_least_one_field?
    else # Create validations
      @errors << 'This recurrence is not valid.' unless active_plan_recurrence?
      @errors << 'This merchant does not support your shipping location.' unless merchant_supports_zipcode?
      @errors << 'This user is not active.' unless user_is_active?
      @errors << 'You are already subscribed to this plan.' unless user_is_not_subscribed_already?
      @errors << 'Options are not valid.' unless options_are_valid?
      @errors << 'Coupon is invalid.' unless redemption_valid?
    end

    @errors.empty?
  end

private
  def attribute(name)
    @subscription_attributes[name]
  end

  # Validations for both Create and Update
  def active_plan_recurrence?
    attribute(:plan).try(:active?) && attribute(:plan_recurrence).try(:is_active?)
  end

  def merchant_supports_zipcode?
    !attribute(:plan).shippable? ||
    (attribute(:shipping_info) && attribute(:plan).merchant.supports_zipcode?(attribute(:shipping_info).zipcode))
  end

  def user_is_active?
    attribute(:user).try(:is_active?)
  end

  def options_are_valid?
    all_active_options_belong_to_plan? &&
    one_option_selected_for_non_multiple?
  end

  def all_active_options_belong_to_plan?
    attribute(:options).all? do |option|
      attribute(:plan).id == option.option_group.plan_id &&
      option.is_active? &&
      option.option_group.is_active?
    end
  end

  def one_option_selected_for_non_multiple?
    selected_non_multiple_option_groups = attribute(:options).map(&:option_group)
    non_multiple_option_groups = attribute(:plan).option_groups.active.select {|option_group| !option_group.allow_multiple? }
    (non_multiple_option_groups - selected_non_multiple_option_groups).empty?
  end

  # Create only
  def user_is_not_subscribed_already?
    attribute(:user).subscriptions.includes(:plan_recurrence).
      has_state(:active, :canceled).
      where(plan_recurrences: { plan_id: attribute(:plan).id }).empty? # The user is not subscribed to this plan already
  end

  def redemption_valid?
    if attribute(:coupon).nil?
      true
    else
      coupon = attribute(:coupon)
      attribute(:user).available_coupon?(coupon) &&
      coupon.available_to_all_plans? || coupon.plans.include?(attribute(:plan))
    end
  end

  # Update only
  def same_plan_as_before?
    attribute(:plan) == @subscription.plan
  end

  def changed_at_least_one_field?
    attribute(:plan_recurrence) != @subscription.plan_recurrence ||
      attribute(:options) != @subscription.options.reject {|o| o.option_type == :onetime } ||
      attribute(:shipping_info) != @subscription.shipping_info
  end
end
