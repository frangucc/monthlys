class Adjustment < ActiveRecord::Base

  belongs_to :subscription
  has_one :user, through: :subscription

  validates_presence_of :subscription, :adjustment_type, :description, :amount_in_usd
  validates :adjustment_type, inclusion: { in: ['charge', 'credit'] }

end
