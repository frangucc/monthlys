class Option < ActiveRecord::Base

  has_one :plan, through: :option_group
  belongs_to :option_group
  has_many :option_recurly_codes

  mount_uploader :image, ImageUploader do
    process resize_to_fill: [130, 85]
  end

  delegate :option_type, to: :option_group

  # Remove this validations after the MP is implemented
  validates_presence_of :option_group, :title, :amount, :invoice_description
  validates_length_of :description, maximum: 40

  # Scopes
  default_scope order('options.order ASC')
  scope :active, where(is_active: true).includes(:option_group).where(option_groups: { is_active: true })

  def amount_per_billing(plan_recurrence)
    case option_type
    when :per_service then amount * plan_recurrence.services_per_billing_cycle
    when :per_billing then amount
    else 0
    end
  end
end
