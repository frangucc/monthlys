class FriendsController < ApplicationController

  load_and_authorize_resource

  def new
    @friends_list = 5.times.map { Friend.new }
  end

  def create
    has_errors = false
    @friends_list = friends_params.each_with_object([]) do |friend_param, list|
      friend = Friend.new(friend_param)
      list << friend
      has_errors = true if !friend.email.blank? && !friend.valid? # Have to trigger .valid? to all object,
                                                                  # otherwise their errors won't be displayed on the front-end
      if friends_params.map {|fp| fp[:email] }.count {|email| friend.email == email && !email.blank? } > 1
        has_errors = true
        friend.errors.add(:email, 'is duplicated')
      end
    end
    unless @friends_list.any? {|f| !f.email.blank? }
      flash.now[:error] = 'You must fill in at least 1 friend'
      has_errors = true
    end
    if has_errors
      render 'new'
    else
      notify_and_add_coupon(@friends_list.reject {|f| f.email.blank? })
    end
  end

private
  def friends_params
    # param[:friends] has the following strcture: {"0" => {"email" => "..."}, "1" => ...}
    ((params[:friends].is_a?(Hash) && params[:friends]) || {}).map {|_, friends_param| friends_param.slice(:email) }
  end

  def notify_and_add_coupon(friends_list)
    friends_list.each do |friend|
      friend.friend = current_user # I am my friend's friend
      friend.save

      # Add friend on ET friends list
      friend.schedule_email_recipient_update
    end

    # Send friend invitation email
    Resque.enqueue(FriendsEmailJob, friends_list.map(&:id))
    # Send user that he got a new coupon
    Resque.enqueue(MarketingEmailsJob, 'coupon_invited_5_friends', current_user.id)
    # Hide header with promotion after inviting friends successfully
    dismiss_on_cookie('header_promo')
    # Asigning coupon for inviting friends
    coupon = Coupon.find_by_coupon_code(Monthly::Application::INVITING_COUPON_CODE)
    if current_user.redemptions.where(coupon_id: coupon.id).empty?
      current_user.redemptions.create(coupon: coupon, is_redeemed: false)
      redirect_to coupons_path, flash: { success: 'Congratulations! You now have a $5 coupon available!' }
    else
      redirect_to coupons_path, flash: { success: 'Thanks!' }
    end
  end

  def hide_flash?
    true
  end
end
