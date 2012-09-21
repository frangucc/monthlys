class MerchantsController < ApplicationController

  load_and_authorize_resource
  layout proc {|c| (c.request.xhr?)? false : 'business' }

  def new
    if user_signed_in? && current_user.roles?(:merchant)
      redirect_to business_path, flash: { notice: 'You already have a merchant account created, our admins will contact you soon. Thanks.' }
    else
      @merchant = Merchant.new
      @merchant.users = [User.new]
    end
  end

  def create
    @merchant = Merchant.new merchant_params.merge({
      is_active: false,
      is_prospect: true,
      delivery_type: Merchant::DELIVERY_TYPE::NATIONWIDE,
      shipping_type: 'free'
    })

    if @merchant.save
      user = current_user
      if !user_signed_in? && @merchant.users.first # Created user!
        user = @merchant.users.first
        sign_in user, bypass: true
        Monthly::Rapi::Accounts.sync(user)
      end
      user.merchant = @merchant
      user.roles << :merchant
      user.save!
      Resque.enqueue(SendMerchantAccountApplicationEmailJob, @merchant.id)
      Resque.enqueue(MarketingEmailsJob, 'new_merchant', user.id)
      redirect_to thank_you_merchant_path(@merchant)
    else
      render :new
    end
  end

  def thank_you
  end

  def terms
  end

private
  def merchant_params
    (params[:merchant] || {}).slice(
      :business_name, :email, :contact_name, :contact_last_name, :address1, :address2, :city,
      :state, :zipcode, :country, :phone, :website, :business_name, :comments, :terms, :users_attributes
    )
  end
end
