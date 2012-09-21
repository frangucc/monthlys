class Shipment < ActiveRecord::Base

  belongs_to :subscription
  has_one :user, through: :subscription

  validates :carrier, presence: true
  validates :tracking_number, presence: true
  validates :subscription, presence: true

end
