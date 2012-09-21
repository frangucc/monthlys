class ReactivateEmailJob
  @queue = :mail_queue

  def self.perform(subscription_id)
    if subscription.expired? # Send to plan detail
    elsif subscription.canceled? # Send to my subscriptions to reactivate
    end

    subscription = Subscription.find(subscription_id)
    user = subscription.user
    template = EmailTemplate.new
    template.assign(user: user, subscription: subscription, plan: subscription.plan)
    content = template.render(template: 'mail/newsletters/reactivate_email.html.erb')
    Monthly::ExactTarget::TriggeredEmail.new(user.email, 'reactivate_email', attributes: {
      "Custom Email" => content
    }).deliver!
  end
end
