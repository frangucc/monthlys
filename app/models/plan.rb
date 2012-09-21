class Plan < ActiveRecord::Base

  has_many :attachments, as: :attachable
  has_many :plan_recurrences
  has_many :subscriptions, through: :plan_recurrences
  has_many :users, through: :subscriptions
  has_many :option_groups
  has_many :options, through: :option_groups
  has_and_belongs_to_many :categories
  belongs_to :merchant
  has_many :plan_documents
  has_many :video_reviews, class_name: 'Marketing::VideoReview'
  has_many :plan_subscription_archives
  has_and_belongs_to_many :coupons
  belongs_to :featured_coupon, class_name: 'Coupon'
  has_and_belongs_to_many :tags

  mount_uploader :thumbnail, ImageUploader do
    process resize_to_fill: [241, 176]
  end
  mount_uploader :icon, ImageUploader do
    process resize_to_fill: [46, 46]
  end
  mount_uploader :merchant_storefront_image, ImageUploader do
    process resize_to_fill: [1150, 485]
  end

  before_create :set_unique_hash
  before_save :update_slug

  default_scope order('plans.name ASC')
  scope :active, where({ status: 'active' })
  scope :has_status, lambda {|*status| where('plans.status IN (?)', status) }
  scope :with_active_merchant, includes(:merchant).where({ merchants: { is_active: true } })
  scope :featured, where(is_featured: true)
  scope :latest, order('plans.activated_at DESC')
  scope :more, includes(:categories).where(categories: { category_group_id: nil })

  validate :status_validations
  validates :attachments, length: { minimum: 1, message: ': please attach at least one master-image' }
  validates :plan_type, presence: true

  define_index do
    indexes(:name)
    indexes(short_description)
    indexes(marketing_phrase)
    indexes(merchant.business_name)
    indexes(tags.keyword)
    indexes(categories(:name))

    where("status = 'active'")

    has(status)
  end

  %w(active inactive pending coming_soon discarded hidden).each do |status_type|
    define_method("#{status_type}?") do
      status == status_type
    end
  end

  class << self
    def available_in_city(city)
      city_id = city.id
      state_id = city.state_id
      self
        .includes([{ merchant: [:cities, :zipcodes, :states] }, :categories])
        .with_active_merchant
        .where('
          (merchants.delivery_type = ?)
          OR (merchants.delivery_type = ? AND cities.id = ?)
          OR (merchants.delivery_type = ? AND zipcodes.city_id = ?)
          OR (merchants.delivery_type = ? AND states.id = ?)',
          Merchant::DELIVERY_TYPE::NATIONWIDE,
          Merchant::DELIVERY_TYPE::CITY_LIST, city_id,
          Merchant::DELIVERY_TYPE::ZIPCODE_LIST, city_id,
          Merchant::DELIVERY_TYPE::STATE_LIST, state_id
        )
    end

    def available_in_zipcode(zipcode)
      city_id = zipcode.city_id
      state_id = City.find(city_id).try(:state_id)
      self
        .includes([{ merchant: [:cities, :zipcodes, :states] }, :categories])
        .with_active_merchant
        .where('
          (merchants.delivery_type = ?)
          OR (merchants.delivery_type = ? AND cities.id = ?)
          OR (merchants.delivery_type = ? AND zipcodes.id = ?)
          OR (merchants.delivery_type = ? AND states.id = ?)',
          Merchant::DELIVERY_TYPE::NATIONWIDE,
          Merchant::DELIVERY_TYPE::CITY_LIST, city_id,
          Merchant::DELIVERY_TYPE::ZIPCODE_LIST, zipcode.id,
          Merchant::DELIVERY_TYPE::STATE_LIST, state_id
        )
    end

    def with_featured_categories
      self.includes(:categories).where(categories: { is_featured: true })
    end

    def with_price_range(min_price, max_price)
      plan_ids = Plan.select('plans.id')
        .joins(:plan_recurrences)
        .where(plan_recurrences: { is_active: true })
        .group('plans.id, plans.name')
        .having('MIN(plan_recurrences.amount) BETWEEN ? AND ?', min_price, max_price)

      self.where(id: plan_ids)
    end

    def slug_or_id(identifier)
      find_by_slug(identifier) || find(identifier)
    end
  end

  def to_s
    self.name
  end

  def to_param
    slug
  end

  def on_sale?
    pr = cheapest_plan_recurrence
    (!pr.nil?) ? !pr.fake_amount.nil? : false
  end

  def subscriptions_count
    @subscriptions_count ||= subscriptions.count
  end

  def shippable?
    # TODO: remove plan_type blank checking once this is released to the MP
    plan_type.blank? || PlanType.get_type(plan_type)[:shippable]
  end

  def subtype_str
    PlanType.get_subtype_str(plan_type)
  end

  def type_key
    PlanType.get_type_key(plan_type)
  end

  def cheapest_plan_recurrence
    if active_plan_recurrences.any?
      active_plan_recurrences.min_by {|pr| pr.amount }
    end
  end

  def active_plan_recurrences
    @active_plan_recurrences ||= plan_recurrences.active.all
  end

  def active_option_groups
    @active_option_groups ||= option_groups.active.all
  end

  def cheapest_plan_recurrence_explanation
    (cheapest_plan_recurrence)? cheapest_plan_recurrence.pretty_explanation : 'n/a'
  end

  def upsell_strategy
    # Check if shipping recurrences are all the same,
    shipping_desc = self.active_plan_recurrences.first.shipping_desc

    if self.active_plan_recurrences.count == 1
      :none
    elsif self.active_plan_recurrences.all? {|pr| pr.shipping_desc == shipping_desc }
      # If they are, they want the user to commit and pay in greater periods, offering them a better cost per month.
      :per_time_commitment
    else
      # If ther are not, they want the user to consume more product, more times a month, offering them a better cost per service.
      :per_number_of_services
    end
  end

  def tax_factor_in_IL
    if self.merchant.taxation_policy == 'no_taxes'
      tax_factor = 0
    else
      tax_factor = self.merchant.tax_rates.where(state_id: 20).first.try(:percentage) || 0
    end
    tax_factor / 100
  end

  def set_unique_hash
    self.unique_hash = SecureRandom.hex(20) until (!unique_hash.blank? && unique_hash?)
  end

  def unique_hash?
    self.class.where({ unique_hash: unique_hash }).empty?
  end

  def update_slug
    if slug.blank?
      self.slug = SlugGeneratorService.new(name).generate_slug do |the_slug|
        Plan.where(slug: the_slug).where('plans.id != ?', self.id).any?
      end
    end
  end

  def applicable_coupon?(coupon)
    !coupon.expired? && (coupon.available_to_all_plans? || coupon.plans.include?(self))
  end

  def status_validations
    if self.active? && self.active_plan_recurrences.empty?
      errors.add(:base, 'Cannot set a plan to active if you don\'t have active plan recurrences')
    end
    if self.discarded? && self.subscriptions.any?
      errors.add(:base, 'Cannot set a plan to discarded if it has subscriptions. You should set it as inactive instead.')
    end
  end
end
