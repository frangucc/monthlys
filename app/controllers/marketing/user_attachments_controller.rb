class Marketing::UserAttachmentsController < ApplicationController

  load_and_authorize_resource

  def new
    @user_attachment = Marketing::UserAttachment.new
  end

  def create
    @user_attachment = Marketing::UserAttachment.new(user_attachment_params)
    if @user_attachment.save
      redirect_to stickit_path, flash: { success: 'Image uploaded successfully. Thank you!' }
    else
      render 'new'
    end
  end

  private
  def user_attachment_params
    (params[:user_attachment] || {}).slice(:name, :email, :image).merge({
      user: user_signed_in? ? current_user : nil,
      attachment_type: 'stickit'
    })
  end
end
