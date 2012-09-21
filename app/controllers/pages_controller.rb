class PagesController < ApplicationController

  authorize_resource class: false
  before_filter :force_non_ssl_with_params

  def home
  end

  def deals
  end

  def featured
    @video_reviews = Marketing::VideoReview.active.featured.limit(3)
  end

  def coming_soon
  end

  def about
  end

  def how_it_works
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def why_monthlys
  end

  def jobs
  end

  def quality
  end

  def guarantee
  end

  def what_is_monthlys
  end

  def affiliate_program
  end

  def beer
  end

  def contact
    if user_signed_in?
      @contact = ContactService.new(name: current_user.full_name, email: current_user.email)
    else
      @contact = ContactService.new
    end
  end

  def contact_submit
    @contact = ContactService.new(contact_params)
    if @contact.deliver
      redirect_to contact_path, flash: { success: 'Got your email. We will be contacting you soon!' }
    else
      flash.now[:error] = @contact.errors
      render 'contact'
    end
  end

  def sitemap
    respond_to do |format|
      format.xml do
        @categories = Category.with_at_least_one_plan.all
        @plans = Plan.has_status(:active).all
      end
    end
  end

  def record
    @video_reviews = Marketing::VideoReview.active.featured.limit(5)
  end

  private
  def contact_params
    ((params[:contact].is_a?(Hash) && params[:contact]) || {}).slice(:name, :email, :content)
  end
end
