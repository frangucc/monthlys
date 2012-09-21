class ApplicationController < ActionController::Base

  layout :customer_layout

  protect_from_forgery

  # Gets the current city as a City object
  helper_method :current_city
  helper_method :current_zipcode

  # Won't display flash below the header
  helper_method :hide_flash?
  helper_method :merchant_storefront?
  helper_method :ms_path
  helper_method :ms_url
  helper_method :filter_params

  before_filter :load_available_cities
  before_filter :load_featured_tags
  before_filter :load_merchant_on_storefront

  # This will be called everytime the user goes to an unauthorized page
  rescue_from CanCan::AccessDenied do |exception|
    if exception.action == :new && exception.subject.is_a?(Merchant)
      redirect_to new_merchant_registration_path
    elsif admin_user_signed_in? && exception.action == :index && exception.subject.is_a?(Category)
      redirect_to admin_dashboard_path
    else
      redirect_to root_path, flash: { error: user_signed_in? ? 'You are not authorized to access this page.' : 'Please log in to access this page' }
    end
    session[:redirect_to] = request.url if request.get? && !request.xhr?
  end

  def after_sign_up_path_for(resource)
    session[:omniauth] = session[:location] = session[:facebook_tries] = nil
    after_sign_in_path_for(resource) # Path for sign_up = path for sign_in
  end

  def after_sign_in_path_for(resource)
    (session[:redirect_to])? session[:redirect_to].to_s : root_url
  end

  def after_sign_out_path_for(resource)
    if merchant_storefront?
      merchant_storefront_path(@merchant.custom_site_url)
    else
      root_url
    end
  end

  def current_city
    geocoder_service.city
  end

  def current_zipcode
    geocoder_service.zipcode
  end

  def hide_flash?
    false
  end

  def customer_layout
    if request.xhr?
      false
    elsif merchant_storefront?
      'merchant_storefront'
    else
      'application'
    end
  end

  def merchant_storefront?
    !! (params[:custom_site_url] && @merchant)
  end

  def ms_path(original_path)
    if merchant_storefront?
      "/#{@merchant.custom_site_url}#{original_path}"
    else
      original_path
    end
  end

  def ms_url(original_path)
    new_path = if merchant_storefront?
      "#{root_url}#{@merchant.custom_site_url}#{original_path}"
    else
      "#{root_url}#{original_path.gsub(/^\//, '')}"
    end
  end

  def filter_params
    ((params[:filter].is_a?(Hash) && params[:filter]) || {}).slice(:discover, :min_price, :max_price, :plan_type)
  end

protected
  # use as a before filter to force ssl works with long query strings
  def force_ssl_with_params
    if !request.ssl? && ['staging', 'production'].include?(Rails.env)
      flash.keep
      redirect_to request.url.gsub!('http', 'https')
    end
  end

  # use as a before filter to force ssl works with long query strings
  def force_non_ssl_with_params
    if request.ssl? && ['staging', 'production'].include?(Rails.env)
       flash.keep
       redirect_to request.url.gsub('https', 'http')
    end
  end

  def load_available_cities
    @available_cities = City.featured
  end

  def load_featured_tags
    @tags = Tag.featured.all
  end

  def load_sidebar_categories
    @grouped_categories = geocoder_service.grouped_available_categories
  end

  def geocoder_service
    session[:geocoder_service] ||= {}
    @geocoder_service ||= GeocoderService.new(current_user, session[:geocoder_service])
  end

  def dismiss_on_cookie(name)
    cookies.permanent[name.to_s] = true
  end

  def load_merchant_on_storefront
    @merchant = Merchant.find_by_custom_site_url(params[:custom_site_url]) if params[:custom_site_url]
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

end
