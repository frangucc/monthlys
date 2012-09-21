ActiveAdmin.register Adjustment do

  menu :parent => "Subscriptions"
  actions :index, :show, :new, :create

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Adjustment') do |adjustment, attributes|
    attributes.delete(:subscription_id)
    attributes.merge({
      subscription: adjustment.subscription ? { id: adjustment.subscription_id, desc: adjustment.subscription.to_s } : nil
    })
  end)

  form do |f|
    f.inputs do
      f.input :subscription, as: :select, collection: Subscription.order("id ASC").all, include_blank: false
      f.input :adjustment_type, as: :select, collection: [['Charge', 'charge'], ['Credit', 'credit']], include_blank: false
      f.input :description, label: 'Invoice description'
      f.input :amount_in_usd
    end
    f.buttons
  end

  sidebar :adjustment_types, only: :index do
    dl do
      dt "Charges"
      dd "Charges can be used to collect a one-off payment from your customers. After the creation of a charge, an invoice will be sent to the customer informing him/her about it."
      dt "Credits"
      dd "Credits can be used to return funds without actually transferring money back to users. Credit remains on the account as a negative balance and will be subtracted from future invoices until satisfied."
    end
  end
  sidebar :refunds, only: :index do
    dl do
      dt "Refunds"
      dd "Refunds can be used to void a user's payment or to transfer money back to them. #{link_to 'Read more', admin_refunds_path}".html_safe
    end
  end

  # Overriding AA Adjustments Controller
  controller do
    def create
      @adjustment = Adjustment.new(params[:adjustment])
      if @adjustment.valid?
        Monthly::Rapi::Adjustments.create(@adjustment)
        redirect_to admin_adjustment_path(@adjustment), flash: { notice: 'Adjustment was successfully created' }
      else
        flash.now[:error] = @adjustment.errors.full_messages
        render :new
      end
    end
  end

end
