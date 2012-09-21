class MerchantSubscriptionJob
  @queue = :mail_queue

  def self.perform(subscription_id, action)
    NotificationMailer.send_merchant_subscription_email(subscription_id, action).deliver
  end
end

class MerchantShippingInfoChangedJob

  @queue = :mail_queue

  def self.perform(old_shipping_info_desc, new_shipping_info_desc, subscriptions_id, user_id)
    NotificationMailer.send_merchant_shipping_info_changed(old_shipping_info_desc, new_shipping_info_desc, subscriptions_id, user_id).deliver
  end
end
