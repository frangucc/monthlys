class State < ActiveRecord::Base

  has_many :cities
  # has_many :shipping_prices
  # has_many :tax_rates

  default_scope order('states.code ASC')

  def to_s
    code
  end
end
