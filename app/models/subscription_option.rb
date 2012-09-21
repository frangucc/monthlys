class SubscriptionOption < ActiveRecord::Base

  belongs_to :subscription
  belongs_to :option
  has_one :option_group, through: :option

end
