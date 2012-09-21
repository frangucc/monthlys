class Coupon < ActiveRecord::Base

  has_and_belongs_to_many :plans
  has_many :redemptions, dependent: :destroy
  has_many :users, through: :redemptions
  has_many :subscriptions, through: :redemptions
  has_many :plan_recurrences, through: :plans

  mount_uploader :image, ImageUploader do
    process resize_to_fill: [80, 80]
  end

  validates :name, presence: true
  validates :coupon_code, uniqueness: true, presence: true
  validates :discount_type, inclusion: { in: ['percent', 'dollars'] }
  validates :discount_in_usd, presence: { if: proc {|c| c.discount_type == 'dollars' } }
  validates :discount_percent, presence: { if: proc {|c| c.discount_type == 'percent' } }

  default_scope order('coupons.coupon_code ASC')
  scope :active, where(is_active: true)
  scope :available_to_all_plans, where(applies_to_all_plans: true)
  scope :available_to_selected_plans, where(applies_to_all_plans: false).where('coupon_code not like ?', 'ES_%')
  scope :eversave, where('coupon_code like ?', 'ES_%')
  scope :totsy, where('coupon_code like ?', 'TOT-%')
  scope :not_available_to_all_users, where(available_to_all_users: false)

  def pretty_discount
    case discount_type
    when 'percent' then "#{discount_percent} %"
    when 'dollars' then "$ #{sprintf('%.02f', discount_in_usd)}"
    end
  end

  def available_to_all_plans?
    self.applies_to_all_plans?
  end

  def expired?
    (self.redeem_by_date && self.redeem_by_date <= Date.current) ||
    (!self.is_active?) ||
    (self.max_redemptions && self.max_redemptions < self.redemptions.count)
  end
end
