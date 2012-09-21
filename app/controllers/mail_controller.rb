class MailController < ApplicationController

  layout 'email'

  def grand_opening
    @user = User.find(params[:id])
  end

  def affiliate_program
  end

  def daily_3
  end

  def coupon_invite_5_friends
    @user = User.find(params[:id])
  end

  def coupon_invite_10_friends
    @user = User.find(params[:id])
  end

  def coupon_invited_5_friends
    @user = User.find(params[:id])
  end

  def coupon_invited_10_friends
    @user = User.find(params[:id])
  end

  def coupon_sign_up
    @friend = Friend.find(params[:id])
    @inviter = User.find(@friend.friend_of_id)
  end

  def coupon_signed_up
    @user = User.find(params[:id])
  end

  def coupon_signed_up_10
    @user = User.find(params[:id])
  end

  def new_merchant
    @user = User.find(params[:id])
  end

  def new_preference
    @user = User.find(params[:id])
  end

  def new_user
    @user = User.find(params[:id])
  end

  def new_user_set_preferences
    @user = User.find(params[:id])
  end

  def set_preferences_reminder
  end

  def fathers_day
  end

  def reactivate_email
    @subscription = Subscription.find(params[:id])
    return head :bad_request unless @subscription && !@subscription.active?

    @plan = @subscription.plan
    @user = @subscription.user

    render 'mail/newsletters/reactivate_email'
  end
end
