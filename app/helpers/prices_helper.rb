module PricesHelper
  def pretty_price(price)
    sprintf('%.02f', price)
  end
end
