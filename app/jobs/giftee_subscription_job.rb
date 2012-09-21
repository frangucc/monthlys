require 'email_template'

class GifteeSubscriptionJob

  @queue = :mail_queue

  def self.perform(subscription_id)
    NotificationMailer.send_giftee_subscription_email(subscription_id).deliver
  end
end
