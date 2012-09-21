class NewsletterSubscribersController < ApplicationController

  load_and_authorize_resource
  skip_load_resource only: [ :create ]

  def create
    @newsletter_subscriber = NewsletterSubscriber.new(newsletter_subscriber_params)
    # @newsletter_subscriber.related_user = current_user if user_signed_in? # TODO: related user used for friends only?
    if @newsletter_subscriber.save
      @newsletter_subscriber.schedule_email_recipient_update
      render json: {
        status: :success,
        messages: ['Subscribed to newsletter successfully!']
      }
    else
      render json: {
        status: :error,
        errors: @newsletter_subscriber.errors.messages
      }
    end
  end

  def newsletter_subscriber_params
    ((params[:newsletter_subscriber].is_a?(Hash) && params[:newsletter_subscriber]) || {}).slice(:email)
  end
end
