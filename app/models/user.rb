class User < ActiveRecord::Base

  has_many :subscriptions
  has_many :plan_recurrences, through: :subscriptions
  has_many :plans, through: :plan_recurrences
  has_many :authentications, dependent: :destroy
  has_many :shipping_infos, dependent: :destroy
  has_many :user_preferences, dependent: :destroy
  belongs_to :merchant
  belongs_to :zipcode
  has_many :redemptions, dependent: :destroy
  has_many :invoices
  has_many :transactions, through: :invoices
  has_many :adjustments, through: :subscriptions

  bitmask :roles, as: [ :merchant, :mp_admin, :merchant_support ]
  delegate :city, to: :zipcode, allow_nil: true

  before_validation :create_or_use_zipcode

  # ET integration
  include Monthly::ExactTarget::Emailable
  acts_as_exact_target_subscriber(attributes: [:full_name, :first_name, :last_name, :phone, :zipcode_str])

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :full_name, :phone, :company_name, :zipcode, :email, :password, :remember_me, :zipcode_str, :password_confirmation

  # Validations
  validate :valid_zipcode
  validates :email, length: { maximum: 100 }, format: { with: /\A[\w.%+-]+@[\w.-]+\.[a-z]+\z/i }

  scope :active, where(is_active: true)
  scope :by_email, order(:email)
  scope :non_test, where(is_test: false)

  def to_s
    self.email
  end

  def first_name
    self.full_name.split.first if self.full_name
  end

  def last_name
    if self.full_name
      first_name, *last_names = self.full_name.split
      last_names.join(' ')
    end
  end

  def create_or_use_zipcode
    self.zipcode = Zipcode.find_or_create_by_number(zipcode_str) if new_record? || (zipcode.blank? && zipcode_str) || zipcode_str_changed?
    true # This shouldn't stop the validation. 'valid_zipcode' method will
  end

  def valid_zipcode
    self.zipcode.errors.full_messages.each {|z_error| self.errors.add(:zipcode, z_error) } if self.zipcode && !self.zipcode.valid?
  end

  def active_for_authentication? # method definied in devise
    super && is_active?
  end

  def oauth_or_already_has_city
    !authentications.any?
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  # User Subscriptions
  def canceled_subscription?(plan)
    subscription_from_plan(plan).canceled?
  end

  def is_subscribed?(plan)
    subscription = subscription_from_plan(plan)
    subscription.try(:active?) || subscription.try(:canceled?)
  end

  def subscription_from_plan(plan)
    subscriptions.has_state(:active, :canceled).includes(:plan_recurrence).where({ plan_recurrences: { plan_id: plan.id } }).first
  end

  def update_zipcode(zipcode_number)
    self.zipcode_str = zipcode_number
    self.save
  end

  # User preferences
  def has_preference?(category_id)
    !! self.preference_from_category(category_id)
  end

  def preference_from_category(category_id)
    self.user_preferences.where(category_id: category_id).first
  end

  # Authentication
  def active_for_authentication?
    super && is_active?
  end

  def has_password?
    ! self.encrypted_password.blank?
  end

  # Coupons stuff
  def available_coupon?(coupon)
    return false if coupon.expired?
    redemptions = self.redemptions.where(coupon_id: coupon.id).all
    return true if coupon.available_to_all_users? && redemptions.empty?
    redemptions.any? { |r| !r.is_redeemed? }
  end

  def find_or_create_redemption_by_coupon(coupon) # This already assumes that this coupon is valid and can be used by the user
    redemption = self.active_redemptions.find {|r| r.coupon == coupon }
    unless redemption
      redemption = self.redemptions.create(coupon: coupon, is_redeemed: false)
    end
    redemption
  end

  def active_redemptions
    self.redemptions.select {|r| r.active? }
  end

  def redeemed_redemptions
    self.redemptions.select {|r| r.redeemed? }
  end

  def expired_redemptions
    self.redemptions.select {|r| r.expired? }
  end

  # Rapi shortcuts
  def inactivate
    # This method calls recurly destroy on the related account so any active
    # subscription will be cancelled and billing info will also be permanently
    # removed from the account.
    Monthly::Rapi::Accounts.close(self)
  end

  def reactivate
    Monthly::Rapi::Accounts.reopen(self)
  end

  def billing_info
    # FIXME We should get rid of this as soon as we have billing infos work
    # merged in local cache.
    @billing_info ||= Monthly::Rapi::Accounts.billing_info(self)
  end

  def set_password(clear_password)
    streches = Monthly::Config::WARDEN_PASSWORD_STRETCHES
    ppw = "#{clear_password}#{Monthly::Config::WARDEN_PASSWORD_PEPPER}"
    self.encrypted_password = ::BCrypt::Password.create(ppw, cost: streches)
  end
end
