class Subscription < ActiveRecord::Base

  belongs_to :user
  belongs_to :plan_recurrence
  belongs_to :shipping_info
  has_one :plan, through: :plan_recurrence
  has_one :merchant, through: :plan
  has_many :subscription_options, dependent: :destroy
  has_many :options, through: :subscription_options
  belongs_to :redemption
  has_one :coupon, through: :redemption
  has_and_belongs_to_many :invoices
  has_many :invoice_lines
  has_many :adjustments
  has_many :shipments, dependent: :destroy
  has_many :subscription_editions, dependent: :destroy

  delegate :merchant, to: :plan
  delegate :shippable?, to: :plan
  delegate :services_per_billing_cycle, to: :plan_recurrence

  default_scope order('subscriptions.id DESC')
  scope :non_test, joins(:user).where(users: { is_test: false })
  scope :has_state, lambda {|*states| where(state: states) }
  scope :eligible_for_shipping_eq, (lambda do |status|
    case status
    when 'active' then has_state(:active, :canceled).where(is_past_due: false, shipping_status: 'active').non_test
    when 'inactive' then where('subscriptions.state IN (?) OR subscriptions.is_past_due = ? OR subscriptions.shipping_status = ?', ['expired'], true, 'inactive')
    else where('1=1')
    end
  end)

  search_methods :eligible_for_shipping_eq

  class << self
    def last_subscription
      self.order('subscriptions.created_at DESC').first
    end
  end

  # Shortcuts
  %w(active canceled expired).each do |state_type|
    define_method("#{state_type}?") do
      state == state_type
    end
  end

  def recurrent_total_without_extras
    base_amount + subscription_options.inject(0) {|total, so| total + (so.unit_amount || 0) * so.quantity }
  end

  def grouped_options
    @gouped_options ||= options.group_by(&:option_group).to_a
  end

  def to_s
    "#{self.id} - #{self.user.email} subscription to #{self.plan.name}"
  end

  def last_paid_invoice
    self.invoices.where(status: 'collected').last_invoice
  end

  def renewal_date
    expired? ? nil : current_period_ends_at.to_date
  end
end
