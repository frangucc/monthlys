class Merchant < ActiveRecord::Base

  has_many :plans
  has_many :subscriptions, through: :plans
  has_and_belongs_to_many :cities
  has_and_belongs_to_many :zipcodes
  has_and_belongs_to_many :states
  has_many :shipping_prices, dependent: :destroy
  has_many :tax_rates, dependent: :destroy
  has_many :users
  has_and_belongs_to_many :faqs
  has_and_belongs_to_many :related_merchants, class_name: 'Merchant', foreign_key: 'related_merchant_id'
  has_many :related_plans, through: :related_merchants, source: :plans

  attr_accessor :zipcodes_list
  accepts_nested_attributes_for :shipping_prices, allow_destroy: true
  accepts_nested_attributes_for :tax_rates

  # ET integration
  include Monthly::ExactTarget::Emailable
  acts_as_exact_target_subscriber(attributes: [:business_name, :location])

  mount_uploader :image, ImageUploader do
    process :resize_to_fill => [76, 76]
  end
  mount_uploader :about_image, ImageUploader do
    process :resize_to_fit => [1150, nil]
  end
  mount_uploader :logo, MerchantLogoUploader
  mount_uploader :storefront_logo, ImageUploader

  before_validation :update_location
  geocoded_by :location, :latitude => :lat, :longitude => :lng
  after_validation :geocode, :if => :location_changed? # auto-fetch coordinates

  module DELIVERY_TYPE
    NATIONWIDE = 1
    CITY_LIST = 2
    ZIPCODE_LIST = 4
    STATE_LIST = 5
  end

  # Validations
  # This validations apply both to AA and the merchant form on the business site.
  validates :business_name, :contact_name, :contact_last_name, :presence => true
  validates :business_name, uniqueness: true
  validates :email, length: { maximum: 100 }, format: { with: Monthly::Application.config.app_config.email_validation_regex }, presence: true
  validates :zipcode, format: { with: /(^\d{5}(-\d{4})?$)|(^$)/, message: 'should be in the form 12345 or 12345-1234' }
  validates :terms, acceptance: true
  validates :delivery_type, inclusion: {
    in: [
      DELIVERY_TYPE::NATIONWIDE,
      DELIVERY_TYPE::CITY_LIST,
      DELIVERY_TYPE::ZIPCODE_LIST,
      DELIVERY_TYPE::STATE_LIST
    ]
  }
  validates :custom_message_type, inclusion: { in: [:shipment_message, :monthlys_message, :none] }
  validates :cutoff_day, inclusion: { in: (1..28) }

  # validates :taxation_policy, inclusion: { in: ['no_taxes', 'tax_plans' 'tax_plans_plus_shippings'] }
  validates :cities, length: { minimum: 1, if: :city_list? }
  validates :states, length: { minimum: 1, if: :state_list? }
  # validates :phone, format: { with: /\A(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?\z/ }
  validate :at_least_one_zipcode, if: :zipcode_list?
  validate :is_user_valid
  validate :cutoff_changed_without_subscriptions

  validates :custom_site_url, uniqueness: true, allow_nil: true,
    format: {
      with: /^(\w[\w-]{4,})?$/,
      message: "should only contain numbers, letters and hyphens (-) and at least 5 characters.",
      allow_nil: true
    }

  default_scope order('merchants.business_name ASC')
  scope :is_active, where({ is_active: true })
  scope :is_inactive, where({ is_active: false })
  scope :is_prospect, where({ is_prospect: true })

  # We are not sending activation emails until the MP is ready
  # after_save :send_activation_email, :if => "self.is_active_changed? && self.is_active?"

  def is_active?
    is_active
  end

  # def send_activation_email
  #   Resque.enqueue(ActivateMerchantNotifierJob, id)
  # end

  def nationwide?
    delivery_type == DELIVERY_TYPE::NATIONWIDE
  end

  def state_list?
    delivery_type == DELIVERY_TYPE::STATE_LIST
  end

  def city_list?
    delivery_type == DELIVERY_TYPE::CITY_LIST
  end

  def zipcode_list?
    delivery_type == DELIVERY_TYPE::ZIPCODE_LIST
  end

  def has_one_plan_only?
    self.plans.count == 1
  end

  def self.nationwide
    where(:delivery_type => NATIONWIDE)
  end

  def update_location
    self.location = "#{address1} #{address2}, #{city}, #{state}, #{country}"
  end

  def to_s
    self.business_name.to_s
  end

  def custom_message_type
    self[:custom_message_type].to_sym
  end

  def subscriptions_count
    subscriptions.count # + plans.select('initial_count').map {|p| p.initial_count }.inject(0, :+)
  end

  def cheapest_plan
    self.plans.min {|p| p.cheapest_plan_recurrence.monthly_cost }
  end

  def at_least_one_zipcode
    errors.add(:zipcodes, " number must be at least 1 if you select zipcode list as delivery type.") unless zipcodes.any?
  end

  def zipcodes_list=(value)
    self[:zipcodes_list] = value
    self.zipcodes = []
    if zipcode_list?
      zipcodes_str = value.split(',').uniq.map {|zip| zip.strip }
      zipcodes_db = Zipcode.where("number IN (?)", zipcodes_str).all
      zipcodes_str.each do |zipcode_str|
        zipcode = zipcodes_db.find {|zip| zip.number == zipcode_str } || Zipcode.new(:number => zipcode_str)
        if zipcode.valid?
          self.zipcodes << zipcode
        else
          errors.add(:zipcodes, "Invalid zipcode: #{zipcode_str}")
        end
      end
    end
  end

  def delivery_area_description
    case self.delivery_type
    when DELIVERY_TYPE::NATIONWIDE then 'Nationwide'
    when DELIVERY_TYPE::CITY_LIST then self.cities_list
    when DELIVERY_TYPE::ZIPCODE_LIST then self.zipcodes_list
    when DELIVERY_TYPE::STATE_LIST then self.states_list
    end
  end

  def shipping_cost_description
    case self.shipping_type
    when 'free' then 'Free'
    when 'flat_rate' then "Flat rate of $#{self.shipping_rate}"
    when 'state_dependant' then self.shipping_prices.map {|sp| "#{sp.state}: #{sp.percentage}% " }.to_sentence
    end
  end

  def zipcodes_list
    self[:zipcodes_list] || zipcodes.map(&:number).join(', ')
  end

  def states_list
    states.map {|state| state.code }.join(', ')
  end

  def cities_list
    cities.join(', ')
  end

  def supports_zipcode?(zipcode) # WARNING: this method should always return true/false since it's used directly on plans#show JSON
    return false if zipcode.blank? || zipcode.city.nil?
    # TODO: this isn't the right place to include this code.. Move somewhere else.
    if nationwide?
      true
    elsif zipcode_list?
      self.zipcodes.map(&:id).include?(zipcode.id) # self.zipcodes.include?(zipcode)
    elsif city_list?
      self.cities.map(&:id).include?(zipcode.city_id) # self.cities.include?(zipcode.city)
    elsif state_list?
      self.states.map(&:id).include?(zipcode.state.id) # self.states.include?(zipcode.state)
    end
  end

  def supports_city?(city)
    return false if city.blank? || city.state.nil?
    # TODO: this isn't the right place to include this code.. Move somewhere else.
    if nationwide?
      true
    elsif city_list?
      self.cities.map(&:id).include?(city.id) # self.cities.include?(zipcode.city)
    elsif state_list?
      self.states.map(&:id).include?(city.state_id) # self.states.include?(zipcode.state)
    else
      false
    end
  end

  def users_attributes=(user_attributes_list)
    user_attributes_list.each do |user_attributes|
      # user_attributes.first is the index of the element in the array.
      new_user = self.users.new(user_attributes.second)
      new_user.is_active = true
    end
  end

  def is_user_valid
    if self.users.any? && !self.users.first.valid?
      self.users.first.errors.full_messages.each {|user_error| self.errors.add(:users, user_error) }
    end
  end

  def shipping_prices_attributes=(shipping_prices_list)
    self.shipping_prices = []
    shipping_prices_list.each do |shipping_price_attributes|
      self.shipping_prices.new(shipping_price_attributes.second) # TODO: figure out why second
    end
  end

  def tax_rates_attributes=(tax_rates_list)
    self.tax_rates = []
    tax_rates_list.each do |tax_rate_attributes|
      self.tax_rates.new(tax_rate_attributes.second)
    end
  end

  # this will be used by the exact target email recipient table
  # or, within exact target, the subscriber list, to be able to filter
  # what type of user is represented by a given email address.  you will
  # want to end up customizing this to fit your needs better
  def exact_target_subscriber_type
    "merchant"
  end

  def cutoff_changed_without_subscriptions
    !(subscriptions.any? && cutoff_day_changed?)
  end
end
