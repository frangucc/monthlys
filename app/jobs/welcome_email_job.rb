require 'email_template'

class WelcomeEmailJob

  @queue = :mail_queue

  def self.perform(user_id)
    user = User.find(user_id)
    template = EmailTemplate.new

    @zipcode = User.find_by_id(user_id).try(:zipcode_str)
    if @zipcode
      @city = Zipcode.find_by_number(@zipcode).try(:city)
      @plans = if @city 
        Plan
          .available_in_city(@city)
          .with_featured_categories
          .has_status(:active)
          .limit(4)
      else
        @plans = []
      end
      @plan = @plans.first if @plans.one?
    end

    template.assign({
      user: user,
      plans: @plans
    })
    content = template.render(template: "mail/new_user.html")
    Monthly::ExactTarget::TriggeredEmail.new(user.email, 'new_user_2', attributes: {
      "Custom Email" => content
    }).deliver!
  end
end
