class BillingInfosController < ApplicationController

  load_and_authorize_resource class: false
  skip_load_resource

  protect_from_forgery except: [ :callback ]

  before_filter :load_recurly_user_account, except: [:callback, :destroy, :delete]
  before_filter :force_ssl_with_params, only: [ :new, :edit, :update, :delete, :destroy ]

  def new
  end

  def show
  end

  def edit
  end

  def delete
    redirect_to ms_path(billing_info_path), flash: { error: 'You don\'t have a billing info to delete.' } unless current_user.billing_info
  end

  def destroy
    if current_user.billing_info
      Monthly::Rapi::Accounts.destroy_billing_info(current_user)
      redirect_to ms_path(billing_info_path), flash: { success: 'Billing info succesfully removed from our database.' }
    else
      redirect_to ms_path(billing_info_path), flash: { error: 'You don\'t have a billing info to delete.' }
    end
  end

  def callback
    redirect_to ms_path(billing_info_path), flash: { success: 'Billing info updated succesfully' }
  end

private
  def load_recurly_user_account
    @account = Monthly::Rapi::Accounts.recurly_account(current_user)
  end
end
