class PlansController < ApplicationController
  include ApplicationHelper

  load_and_authorize_resource find_by: :slug_or_id, except: [:summary, :subscription_archive]
  skip_load_resource only: [ :preview ]

  before_filter :force_non_ssl_with_params

  def index
    # If there are too few plans, show all the plans available in a single page
    @plans = geocoder_service.available_plans_without_category.all

    if admin_user_signed_in? || @plans.count >= Monthly::Application::TOO_FEW_PLANS
      redirect_to root_url
    elsif @plans.empty?
      redirect_to coming_soon_path
    end
  end

  def filtered
    @plans = geocoder_service.available_plans_without_category(filter_params)
    @filter_params = filter_params
    @featured_categories = geocoder_service.available_categories.featured
    load_sidebar_categories
  end

  def show
    return not_found if @plan.pending? || @plan.discarded?
    return redirect_to ms_path(plan_path(@plan)), status: :moved_permanently if @plan.id.to_s == params[:id]
    load_show_data
  end

  def preview
    @plan = Plan.find_by_unique_hash(params[:id])
    return not_found unless @plan
    load_show_data
    render :show
  end

  # This action returns a plan data summary used by the plan preview modal feature.
  def summary
    # We dont use devise load resoure but we want auth
    authorize!(:summary, Plan)
    plan = Plan.find(params[:id])
    return not_found if !plan || plan.pending?

    category = plan.categories.first
    category_group = category.category_group
    json = {
      id: plan.id,
      name: plan.name,
      short_description: plan.short_description,
      price: plan.cheapest_plan_recurrence.pretty_explanation,
      details_url: Rails.application.routes.url_helpers.plan_path(plan),
      merchant_name: plan.merchant.business_name,
      video_url: plan.merchant.video_url.blank? ? nil : get_youtube_video_embed(plan.merchant.video_url, true),
      category_name: category.name,
      category_url: Rails.application.routes.url_helpers.category_path(category),
      category_group_name: category_group.name,
      category_group_url: Rails.application.routes.url_helpers.category_group_path(category_group),
    }

    respond_to do |format|
      format.json { render(json: json) }
      format.all { not_found }
    end
  end

  def subscription_archive
    respond_to do |format|
      format.json do
        json = PlanSubscriptionArchive.where(plan_id: params[:id].to_i).to_json(only: [:title],
                                                                                methods: [:image_url, :sent_on_display])
        render(json: json)
      end
      format.all { not_found }
    end
  end

  private

  def load_show_data
    return not_found if merchant_storefront? && @plan.merchant != @merchant
    @merchant = @plan.merchant

    # Stuff for the configuration drop downs
    @option_groups = @plan.active_option_groups
    @plan_recurrences = @plan.active_plan_recurrences
    @plan.attachments.build if @plan.attachments.empty?
    @selected_plan_recurrence = @plan.cheapest_plan_recurrence
    load_sidebar_categories

    @has_archive = @plan.plan_subscription_archives.count() > 0

    @featured_coupon = @plan.featured_coupon
    @is_on_sale = (@plan.cheapest_plan_recurrence.nil? ? false : !@plan.cheapest_plan_recurrence.fake_amount.nil?)
    @free_shipping = (@merchant.shipping_type == 'free') && @plan.shippable?
    @location_supported = @merchant.supports_zipcode?(geocoder_service.zipcode) || @merchant.supports_city?(geocoder_service.city)
    @is_subscribed = user_signed_in? && current_user.is_subscribed?(@plan)
    @subscription = user_signed_in? && current_user.subscription_from_plan(@plan)
    @related_plans = @merchant.plans.active.where('id != ?', @plan.id).limit(5).all
    @deal_source = Marketing::DealSource.find_by_url_code(params[:source])
    coupon = Coupon.find_by_coupon_code(params[:coupon])
    @deal_coupon = coupon if coupon && @plan.applicable_coupon?(coupon)

    @video_reviews = @plan.video_reviews.active
    @featured_video_review = @video_reviews.featured.limit(1) if @video_reviews.any?
  end

end
