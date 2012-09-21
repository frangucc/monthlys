class SendContactEmailJob

  @queue = :mail_queue

  def self.perform(form_data)
    NotificationMailer.send_contact_email(form_data).deliver
  end
end
