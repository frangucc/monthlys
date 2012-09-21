class ShippingInfosController < ApplicationController

  load_and_authorize_resource
  skip_load_resource only: [ :index, :new, :create ]
  before_filter :force_ssl_with_params

  def index
    @shipping_infos = current_user.shipping_infos.active
  end

  def show
  end

  def new
    @shipping_info = current_user.shipping_infos.new
  end

  def create
    @shipping_info = current_user.shipping_infos.new(shipping_info_params)
    @address_validator = AddressValidator.new(shipping_info_params)
    if @address_validator.valid?
      @shipping_info.is_active = true
      @shipping_info.save
      redirect_to ms_path(shipping_infos_path), flash: { success: 'Shipping info created successfully!' }
    else
      render :new
    end
  end

  def edit_confirmation
    @related_subscriptions = related_active_subscriptions
    redirect_to edit_shipping_info_path(@shipping_info) if @related_subscriptions.empty?
  end

  def edit
  end

  def update
    old_shipping_desc = @shipping_info.pretty_address
    @address_validator = AddressValidator.new(shipping_info_params)
    if @address_validator.valid?
      @shipping_info.update_attributes(shipping_info_params)
      if related_active_subscriptions.any?
        Resque.enqueue(MerchantShippingInfoChangedJob, old_shipping_desc, @shipping_info.pretty_address, related_active_subscriptions.map(&:id), current_user.id)
      end
      redirect_to ms_path(shipping_infos_path), flash: { success: 'Shipping information updated successfully!' }
    else
      render :edit
    end
  end

  def delete
    @related_subscriptions = related_active_subscriptions
    @related_merchants = @related_subscriptions.map(&:merchant).uniq
    @other_shipping_infos = current_user.shipping_infos.active.reject {|si| si == @shipping_info }

    if !@related_subscriptions.empty? && @other_shipping_infos.empty?
      redirect_to shipping_infos_path, flash: {
        error: '
          This address is associated with a subscription and can\'t be deleted. Please <a href="/shipping_infos/new">add new destination address for that subscription </a>and try again.
        '
      }
    elsif out_of_area?(@other_shipping_infos, @related_merchants)
      redirect_to shipping_infos_path, flash: {
        error: '
          This address is associated with a subscription, and you don\'t have any addresses in the merchant\'s area of service. Please <a href="/shipping_infos/new">add new shipping info</a> and try again.
        '
      }
    end
  end

  def destroy
    if related_active_subscriptions.any? && new_shipping_info
      ActiveRecord::Base.transaction do
        @shipping_info.subscriptions.has_state(:active, :canceled).update_all(shipping_info_id: new_shipping_info.id)
        @shipping_info.update_attribute(:is_active, false)
      end
      Resque.enqueue(MerchantShippingInfoChangedJob, @shipping_info.pretty_address, new_shipping_info.pretty_address, related_active_subscriptions.map(&:id), current_user.id)
      redirect_to ms_path(shipping_infos_path), flash: { success: 'Shipping Info deleted successfully.' }
    elsif related_active_subscriptions.any?
      redirect_to ms_path(shipping_infos_path), flash: {
        error: "Shipping Info already in use by #{related_active_subscriptions.count} subscriptions. You cannot delete it!"
      }
    else
      @shipping_info.update_attribute(:is_active, false)
      redirect_to ms_path(shipping_infos_path), flash: { success: 'Shipping Info deleted successfully.' }
    end
  end

private
  def shipping_info_params
    params[:shipping_info].slice(:first_name, :last_name, :address1, :address2, :zipcode_str, :city, :state_id, :phone)
  end

  def related_active_subscriptions
    @related_active_subscriptions ||= @shipping_info.subscriptions.has_state(:active, :canceled).all
  end

  def new_shipping_info
    @new_shipping_info_pointer ||= current_user.shipping_infos.active.find_by_id(params[:new_shipping_info_id])
  end

  def out_of_area?(shipping_infos_list, merchants_list)
    shipping_infos_list.any? do |si|
      merchants_list.any? {|m| !m.supports_zipcode?(si.zipcode) }
    end
  end
end
