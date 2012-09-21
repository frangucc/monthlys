class MerchantStorefrontSiteConstraint

  def matches?(request)
    Merchant.where(custom_site_url: request.params[:custom_site_url]).any?
  end
end
