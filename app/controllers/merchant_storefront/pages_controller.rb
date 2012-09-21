class MerchantStorefront::PagesController < ApplicationController
  include MerchantStorefrontHelper

  def about
  end

  def how_it_works
    @faqs = @merchant.faqs
  end

  def contact
    if user_signed_in?
      @contact = ContactService.new(name: current_user.full_name, email: current_user.email)
    else
      @contact = ContactService.new
    end
  end

  def contact_submit
    @contact = ContactService.new(params[:contact])
    if @contact.deliver
      redirect_to merchant_storefront_contact_path(@merchant.custom_site_url), flash: { successs: 'Got your email. We will be contacting you soon!' }
    else
      flash.now[:errors] = @contact.errors
      render 'contact'
    end
  end
end
