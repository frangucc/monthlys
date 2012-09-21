class Marketing::NewslettersController < ApplicationController

  load_and_authorize_resource

  before_filter :load_newsletter_data

  layout 'email'

  def show
    respond_to do |format|
      format.html {}
      format.text {}
    end
  end

  private
  def load_newsletter_data
    @plan = @newsletter.plan
    @show_three_block_area = !(@newsletter.first_block_heading.blank? && @newsletter.second_block_heading.blank? && @newsletter.third_block_heading.blank?)

    if @plan
      @coupon = @newsletter.coupon

      @featured_price = if !@newsletter.featured_price.blank?
        @newsletter.featured_price # Override
      elsif @coupon
        totals_pricing = SubscriptionManager::TotalsPricing.totals({
          plan_recurrence: @plan.cheapest_plan_recurrence,
          options: [],
          coupon: @coupon
        })
        totals_pricing[:first_time_without_extras] # cheapest_plan_recurrence - coupon
      else
        @plan.cheapest_plan_recurrence.pretty_amount # cheapest_plan_recurrence
      end

      @featured_billing_cycle = if !@newsletter.featured_billing_cycle.blank?
        @newsletter.featured_billing_cycle # Override
      else
        @plan.cheapest_plan_recurrence.billing_cycle.inspect # cheapest_plan_recurrence
      end
    end

    @best_sellers = @newsletter.best_sellers.all

  end
end
