class ShippingInfo < ActiveRecord::Base
  belongs_to :user
  belongs_to :zipcode
  has_many :subscriptions

  attr_accessor_with_default(:state_id) { self.zipcode && self.zipcode.state && self.zipcode.state.id }

  # Callbacks
  before_validation :load_zipcode

  # Scope
  default_scope order('shipping_infos.created_at ASC')
  scope :active, where(is_active: true)

  def full_name
    "#{first_name} #{last_name}"
  end

  def pretty_address
    [ "#{address1} #{address2}",
      "#{city} - #{zipcode.state}, #{zipcode.number}",
      "#{zipcode.country}" ]
  end

  def state
    zipcode.state
  end

  def load_zipcode
    self.zipcode = Zipcode.find_or_create_by_number(zipcode_str)
  end
end
