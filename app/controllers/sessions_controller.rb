class SessionsController < Devise::SessionsController

  # DO NOT UNCOMMENT. IT FUCKS UP EVERYTHING
  # authorize_resource class: false

  def user_location # This is used for the HTML5 Geolocation
    session[:longitude] = params[:longitude]
    session[:latitude] = params[:latitude]
    session[:city_id] = GeocoderService(current_user, session).city_id
    render js: "window.location = #{user_session_path};"
  end

  def create
    respond_to do |format|
      format.json do
        if warden.authenticate?(scope: resource_name)
          resource = warden.authenticate(scope: resource_name)

          scope = Devise::Mapping.find_scope!(resource_name)
          sign_in(scope, resource)

          render json: {
            status: :success,
            redirect_to: after_sign_in_path_for(resource)
          }
        else
          render json: {
            status: :error,
            errors: ['Invalid email or password']
          }
        end
      end
      format.html { super }
    end
  end

  def form
    render partial: 'sessions_frame'
  end

  def hide_flash?
    true
  end
end
