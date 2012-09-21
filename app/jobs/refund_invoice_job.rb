class RefundInvoiceJob
  @queue = :mail_queue

  def self.perform(refund_id)
    NotificationMailer.send_user_refund_email(refund_id).deliver
  end
end
