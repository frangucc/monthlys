class SendMerchantAccountApplicationEmailJob

  @queue = :mail_queue

  def self.perform(merchant_id)
    NotificationMailer.send_merchant_account_application_email(merchant_id).deliver
  end
end
