class CategoryGroupsController < ApplicationController

  load_and_authorize_resource

  def show
    @categories = geocoder_service.available_categories
    @grouped_categories = geocoder_service.grouped_available_categories

    @plans = geocoder_service.available_plans_with_category_group(@category_group)
  end

end
