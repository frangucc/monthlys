require 'email_template'

class FriendsEmailJob

  @queue = :mail_queue

  def self.perform(friends_id)
    template = EmailTemplate.new
    Friend.where(id: friends_id).each do |friend|
      template.assign(friend: friend, inviter: User.find(friend.friend_of_id))
      content = template.render(template: "mail/coupon_sign_up.html")
      Monthly::ExactTarget::TriggeredEmail.new(friend.email, 'coupon_sign_up', attributes: {
        "Custom Email" => content
      }).deliver!
    end
  end
end
