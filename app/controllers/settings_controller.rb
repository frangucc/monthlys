class SettingsController < ApplicationController

  load_and_authorize_resource class: false

  before_filter :force_ssl_with_params, only: [ :edit, :update ]

  def edit
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)
    if @user.update_without_password(user_params)
      # Updating the city drop-down with the new zipcode the user entered
      session.delete(:city_id)

      # Sync changes with recurly and exacttarget
      Monthly::Rapi::Accounts.sync(@user)
      @user.schedule_email_recipient_update

      redirect_to ms_path(edit_settings_path), flash: { success: 'You successfully updated your personal info.' }
    else
      render :edit
    end
  end

  def edit_password
    @user = User.find(current_user.id)
  end

  def update_password
    @user = User.find(current_user.id)
    if save_user_password
      # Sign in the user by passing validation in case his password changed
      sign_in @user, bypass: true
      redirect_to ms_path(edit_password_settings_path), flash: {
        success: "Password updated successfully, you may now log in using <strong>#{@user.email}</strong>".html_safe
      }
    else
      render :edit_password
    end
  end

  def enter_zip
    dismiss_on_cookie(:zipcode_prompt)
    @zipcode = Zipcode.find_or_create_by_number(params[:zipcode_str])
    if user_signed_in?
      @user = current_user
      geocoder_service.clear if @user.update_attributes(zipcode_str: params[:zipcode_str])
    else
      geocoder_service.set_zipcode(@zipcode) if @zipcode.errors.empty?
    end
    render partial: 'enter_zip'
  end

  def update_location
    if params.key?(:city_id) && (city = City.find_by_id(params[:city_id]))
      geocoder_service.set_city(city)
    elsif params[:type] && admin_user_signed_in?
      geocoder_service.set_plans_type(params[:type])
    elsif params.key?(:zipcode_handler) && params[:zipcode_handler].key?(:zipcode_str)
      zipcode = Zipcode.find_or_create_by_number(params[:zipcode_handler][:zipcode_str])
      if zipcode.valid?
        if user_signed_in?
          current_user.update_zipcode(zipcode.number)
          geocoder_service.clear
        else
          geocoder_service.set_zipcode(zipcode)
        end
      else
        flash[:error] = zipcode.errors.full_messages
      end
    end
    redirect_to root_url
  end

  def persistent_dismiss
    if %w(get_started header_promo zipcode_prompt).include?(params[:name])
      dismiss_on_cookie(params[:name])
      render nothing: true
    else
      redirect_to status: :bad_request
    end
  end

private
  def user_params
    params[:user].slice(:full_name, :email, :phone, :company_name, :zipcode_str)
  end

  def user_password_params
    params[:user].slice(:current_password, :password, :password_confirmation)
  end

  def save_user_password
    if user_password_params[:password].blank? || user_password_params[:password_confirmation].blank?
      @user.errors.add(:password, 'can\'t be blank')
      false
    elsif @user.has_password?
      @user.update_with_password(user_password_params)
    else
      @user.update_attributes(user_password_params)
    end
  end
end
