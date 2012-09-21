class NewsletterSubscriber < ActiveRecord::Base

  belongs_to :related_user, foreign_key: 'related_user_id', class_name: 'User'

  # ET integration
  include Monthly::ExactTarget::Emailable
  acts_as_exact_target_subscriber(attributes: [], subscriber_list: :friends)

  validates :email, format: { with: Monthly::Application.config.app_config.email_validation_regex, message: 'Email is invalid' }
  validate :email_was_not_taken

  def email_was_not_taken
    if newsletter_subscriber_with_same_email? || user_with_same_email?
      errors.add(:email, 'has already been taken, you can\'t use it again')
    end
  end

  def newsletter_subscriber_with_same_email?
    self.class.where(email: self.email).any?
  end

  def user_with_same_email?
    User.where(email: self.email).any?
  end
end
