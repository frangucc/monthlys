# 
# To render a partial:
# t = EmailTemplate.new
# t.assign({
#   local_variable: User.all
#   .. other local variables ..
# })
# content = t.render(template: 'mail/_welcome_email.html')
#

class EmailTemplate < ActionView::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  def initialize
    super(Rails.root.join('app', 'views'))
  end

  def default_url_options
    config.action_mailer.default_url_options
  end

  def asset_host
    config.action_mailer.asset_host
  end
end
