class MerchantStorefront::PlansController < ApplicationController

  layout 'merchant_storefront'

  authorize_resource

  before_filter :load_merchant # TODO: move this before_filter to all the controllers under merchant_storefront

  include MerchantStorefrontHelper

  def home
    @plans = @merchant.plans.all
  end

  def index
    @plans = @merchant.plans.all
    redirect_to ms_path(plan_path(@plans.first)) if @plans.one?
  end

private
  def load_merchant
    @merchant = Merchant.find_by_custom_site_url(params[:custom_site_url])
  end
end
