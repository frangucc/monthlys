class SearchesController < ApplicationController
  load_and_authorize_resource class: false

  def show
    q = params[:q]

    respond_to do |format|
      format.json do
        render json: SearchService.json_search(q, limit: 6)
      end
    end
  end
end
