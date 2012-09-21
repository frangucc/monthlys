class ShippingPrice < ActiveRecord::Base

	belongs_to :merchant
  belongs_to :state

end
