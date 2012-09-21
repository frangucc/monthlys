class NotificationMailerController < ApplicationController

  layout 'email'

  def send_giftee_subscription_email
    @subscription = Subscription.find(params[:id])
  end

  def send_user_tracking_number_email
    @shipment = Shipment.find(params[:id])
    @shipping_info = @shipment.subscription.shipping_info
    @user = @shipment.subscription.user
  end

end
