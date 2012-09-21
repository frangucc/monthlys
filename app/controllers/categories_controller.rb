class CategoriesController < ApplicationController

  load_and_authorize_resource
  skip_load_resource only: [ :index ]

  before_filter :force_non_ssl_with_params

  def index
    @featured_categories = @categories.featured
    load_available_categories
    @plans = geocoder_service.available_plans_without_category
    if @plans.empty?
      redirect_to coming_soon_path
    elsif !admin_user_signed_in? && @plans.count < Monthly::Application::TOO_FEW_PLANS
      redirect_to plans_path
    end
  end

  def show
    @plans = geocoder_service.available_plans_with_category(@category)
    load_available_categories

    if @plans.empty?
      redirect_to root_path
    elsif @plans.one?
      plan = @plans.first
      redirect_to (plan.pending?)? preview_plan_path(plan.unique_hash) : plan_path(plan)
    end

    @latest_plans = @plans.latest.limit(3)
    @related_categories = (@category.related_categories & @categories)
  end

  def highlights
    respond_to do |format|
      format.json { render json: TagHighlightsService.get_categories_json }
      format.all { not_found }
    end
  end

  def load_available_categories
    @categories = geocoder_service.available_categories
    @grouped_categories = geocoder_service.grouped_available_categories
  end
end
