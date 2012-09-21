class UserPreferencesController < ApplicationController

  load_and_authorize_resource
  skip_load_resource only: [ :index, :my_preferences, :create ]

  def index
    @categories = Category.all
  end

  def my_preferences
    if user_signed_in?
      categories_id = current_user.user_preferences.map(&:category_id)
      @categories = Category.where(id: categories_id).limit(12).all
    else
      @categories = []
    end
  end

  def create
    if valid_user_preference?
      if current_user.zipcode
        @user_preference = current_user.user_preferences.create(user_preference_params.merge({
          status: 'active',
          zipcode: current_user.zipcode
        }))
        render json: { 
          status: :success, 
          message: "Preference created successfully. We'll notify you when it becomes available to your zipcode (#{current_user.zipcode.number})!",
          user_preference: @user_preference
        }
      else
        render json: { status: :error, message: 'You must have a valid zipcode selected.' }
      end
    else
      render status: :bad_request
    end
  end

  def destroy
    @user_preference.destroy
    render json: { 
      status: :success, 
      message: 'Preference removed successfully!',
      user_preference: @user_preference
    }
  end

private
  def user_preference_params
    params[:user_preference].slice(:category_id)
  end

  def valid_user_preference?
    current_user.user_preferences.where({ category_id: user_preference_params[:category_id] }).empty?
  end
end
