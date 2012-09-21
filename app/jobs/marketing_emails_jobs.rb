require 'email_template'

class MarketingEmailsJob

  @queue = :mail_queue

  def self.perform(et_email_name, user_id)
    user = User.find(user_id)
    template = EmailTemplate.new
    template.assign(user: user)
    content = template.render(template: "mail/#{et_email_name}.html")
    Monthly::ExactTarget::TriggeredEmail.new(user.email, et_email_name, attributes: {
      "Custom Email" => content
    }).deliver!
  end
end
