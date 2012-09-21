class Friend < ActiveRecord::Base

  belongs_to :user
  belongs_to :friend, foreign_key: 'friend_of_id', class_name: 'User'

  # ET integration
  include Monthly::ExactTarget::Emailable
  acts_as_exact_target_subscriber(attributes: [], subscriber_list: :friends)

  validates :email, format: { with: Monthly::Application.config.app_config.email_validation_regex }
  validate :email_was_not_taken

  def email_was_not_taken
    if self.class.where('friends.email = ? AND friends.id != ?', self.email, self.id).any? || User.where(email: self.email).any?
      errors.add(:email, 'has already been taken, you cannot use it again')
    end
  end
end
