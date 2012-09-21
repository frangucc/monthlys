class TagsController < ApplicationController

  load_and_authorize_resource find_by: :slug, only: [ :show ]
  before_filter :force_non_ssl_with_params, except: [ :highlights ]

  def show
    @plans = @tag.plans
    load_sidebar_categories
  end

  def highlights
    respond_to do |format|
      format.json { render(json: TagHighlightsService.get_tag_json(params[:id])) }
      format.all { not_found }
    end
  end
end
