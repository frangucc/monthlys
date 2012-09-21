module NotificationMailerHelper

  include Marketing::NewslettersHelper

  def pretty_price(price)
    sprintf('%.02f', price)
  end
end
