class TrackingNumberJob
  @queue = :mail_queue

  def self.perform(shipment_id)
    shipment = Shipment.find(shipment_id)
    user = shipment.user
    template = EmailTemplate.new
    template.assign(shipment: shipment, user: user)
    content = template.render(template: 'mail/tracking_number_email.html')
    Monthly::ExactTarget::TriggeredEmail.new(user.email, 'tracking_number_email', attributes: {
      "Custom Email" => content
    }).deliver!
  end
end
