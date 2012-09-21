class OptionGroup < ActiveRecord::Base

  belongs_to :plan
  has_many :options

  # Remove this validations after the MP is implemented
  validates :plan, :description, :option_type, :presence => true

  # Scopes
  default_scope order('option_groups.order ASC')
  scope :active, where(is_active: true)

  # type = 'onetime' | 'per_billing' | 'per_service' | 'nocharge'
  [:onetime, :per_service, :nocharge, :per_billing].each do |type|
    define_method("#{type}?") do
      option_type == type
    end
  end

  def to_s
    self.description
  end

  def option_type
    self[:option_type].try(:to_sym)
  end
end
