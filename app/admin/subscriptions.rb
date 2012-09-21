ActiveAdmin.register Subscription do

  actions :index, :show, :reactivate, :cancel, :edit, :update

  around_filter &Monthly::AdminActivityLogger.get_around_filter_block_for('Subscription', { extra_actions: %w(reactivate cancel) })

  filter :merchant, as: :select, collection: proc { Merchant.order('business_name ASC').all }
  filter :redemption_coupon_coupon_code, label: 'Coupon code', as: :string
  filter :state, as: :select, label: 'Billing Status', collection: %w(active canceled expired)
  filter :eligible_for_shipping, as: :select, collection: ['active', 'inactive'], label: 'Shipping Status'
  filter :plan, as: :select, collection: proc { Plan.order('name ASC').all }
  filter :user, as: :select, collection: proc { User.order('email ASC').all.map {|u| [u.email, u.id] } }
  filter :user_is_test, as: :select, label: 'Is test'
  filter :created_at

  form partial: 'form'

  index do
    column :id
    column :created_at do |s|
      s.created_at.strftime('%m/%d/%Y')
    end
    column :plan, sortable: false
    column 'User' do |subscription|
      link_to subscription.user.email, admin_user_path(subscription.user)
    end
    column "Billing Status", :state do |s|
      if s.is_past_due?
        "<span class=\"past-due\">#{s.state} (past due)</span>".html_safe
      else
        s.state
      end
    end
    column 'Coupon', :coupon do |s|
      s.coupon ? link_to(s.coupon.coupon_code, admin_coupon_path(s.coupon)) : ''
    end
    column 'Recurrent total', sortable: :recurrent_total do |s|
      "$#{s.recurrent_total}"
    end
    column 'First time total', sortable: :first_time_total do |s|
      "$#{s.first_time_total}"
    end
    column 'Last Payment' do |s|
      s.last_paid_invoice.created_at.strftime('%m/%d/%Y')
    end
    default_actions
  end

  sidebar :billing_statuses, only: :index do
    dl do
      dt "Active"
      dd "Subscriptions that are valid for the current time. Users are being charged for all subscriptions on this state."
      dt "Canceled"
      dd "Subscriptions that are valid for the current time but will not renew because a cancelation was requested."
      dt "Expired"
      dd "Subscriptions that have expired and are no longer valid."
    end
  end

  sidebar :shipping_statuses, only: :index do
    dl do
      dt "Active"
      dd "Subscriptions eligible to be shipped. Gets all non-test subscriptions with active and canceled billing statuses minus past due subscriptions."
      dt "Inactive"
      dd "Subscriptions not eligible to be shipped. Gets all subscriptions with expired billing statuses plus past due subscriptions."
    end
  end

  EMPTY_CSV_FIELD = '-'

  csv do
    column('ID') do |s|
      s.id
    end

    # Created at
    column('Created at') do |s|
      s.created_at.strftime('%m/%d/%Y')
    end

    column 'Billing status' do |s|
      if s.is_past_due?
        "#{s.state} (past due)"
      else
        s.state
      end
    end

    column 'Cancellation date' do |s|
      s.canceled_at ? s.canceled_at.strftime('%m/%d/%Y') : EMPTY_CSV_FIELD
    end

    column 'Expiration date' do |s|
      s.expired_at ? s.expired_at.strftime('%m/%d/%Y') : EMPTY_CSV_FIELD
    end

    column 'Next renewal date' do |s|
      s.renewal_date ? s.renewal_date.strftime('%m/%d/%Y') : 'Will not renew'
    end

    column 'Merchant' do |s|
      s.merchant.business_name
    end

    column 'User last name' do |s|
      s.user.last_name
    end

    column 'User first name' do |s|
      s.user.first_name
    end

    column 'User email' do |s|
      s.user.email
    end

    # Shipping stuff
    column 'Shipping last name' do |s|
      s.shippable? ? s.shipping_info.last_name : EMPTY_CSV_FIELD
    end

    column 'Shipping first name' do |s|
      s.shippable? ? s.shipping_info.first_name : EMPTY_CSV_FIELD
    end

    column 'Shipping Address 1' do |s|
      s.shippable? ? s.shipping_info.address1 : EMPTY_CSV_FIELD
    end

    column 'Shipping Address 2' do |s|
      s.shippable? ? s.shipping_info.address2 : EMPTY_CSV_FIELD
    end

    column 'City' do |s|
      s.shippable? ? s.shipping_info.city : EMPTY_CSV_FIELD
    end

    column 'State' do |s|
      s.shippable? ? s.shipping_info.state.code : EMPTY_CSV_FIELD
    end

    column 'ZIP code' do |s|
      s.shippable? ? s.shipping_info.zipcode.number : EMPTY_CSV_FIELD
    end

    column 'Country' do
      'US'
    end

    column 'Shipping phone' do |s|
      s.shippable? ? s.shipping_info.phone : EMPTY_CSV_FIELD
    end

    # Gifting

    column 'Is Gift?' do |s|
      s.is_gift? ? 'yes' : 'no'
    end

    column 'Giftee name' do |s|
      s.giftee_name? ? s.giftee_name : EMPTY_CSV_FIELD
    end

    column 'Giftee email' do |s|
      s.giftee_email? ? s.giftee_email : EMPTY_CSV_FIELD
    end

    column 'Gift message' do |s|
      s.gift_description? ? s.gift_description : EMPTY_CSV_FIELD
    end

    column 'Notify giftee on email' do |s|
      s.notify_giftee_on_email? ? 'yes' : 'no'
    end

    column 'Notify giftee on shipment' do |s|
      s.notify_giftee_on_shipment? ? 'yes' : 'no'
    end

    # Plan And Options

    column 'Plan name' do |s|
      s.plan.name
    end

    5.times do |index|
      column "Option #{index + 1}A" do |s|
        option_group = s.grouped_options[index]
        option_group ? option_group[0].description : EMPTY_CSV_FIELD
      end

      column "Option #{index + 1}B" do |s|
        options = s.grouped_options[index]
        options && options.any? ? options[1].map(&:title).join(', ') : EMPTY_CSV_FIELD
      end
    end

    column 'Shipping frequency' do |s|
      s.plan_recurrence.shipping_desc
    end

    column 'Plan cost' do |s|
      s.recurrent_total_without_extras
    end

    column 'Shipping' do |s|
      s.shipping_amount ? s.shipping_amount : EMPTY_CSV_FIELD
    end

    column 'Taxes' do |s|
      s.recurrent_tax_amount
    end

    column 'Recurrent Total' do |s|
      s.recurrent_total
    end

    column 'Recurrent Total Frequency' do |s|
      s.plan_recurrence.billing_recurrence_in_words
    end

    column 'First time income' do |s|
      s.first_time_total
    end

    column 'Coupon code' do |s|
      s.coupon ? s.coupon.coupon_code : EMPTY_CSV_FIELD
    end

    column 'Last payment date' do |s|
      s.last_paid_invoice ? s.last_paid_invoice.created_at.strftime('%m/%d/%Y') : EMPTY_CSV_FIELD
    end

    column 'Last payment status' do |s|
      s.last_paid_invoice ? s.last_paid_invoice.status : EMPTY_CSV_FIELD
    end

    column 'Last payment amount' do |s|
      s.last_paid_invoice ? s.last_paid_invoice.total_in_usd.to_s : EMPTY_CSV_FIELD
    end

    column 'Card Type' do |s|
      s.cc_type || EMPTY_CSV_FIELD
    end

    column 'Last 4 digits' do |s|
      s.cc_last_four || EMPTY_CSV_FIELD
    end

    column 'Exp Date' do |s|
      s.cc_exp_date || EMPTY_CSV_FIELD
    end

    column 'Monthlys commission rate' do |s|
      s.merchant.commission_rate ? "#{s.merchant.commission_rate}%" : 'n/a'
    end

    column 'Merchant\'s first installment' do |s|
      s.merchant.first_installment ? "#{s.merchant.first_installment}%" : 'n/a'
    end

    column 'Merchant\'s ID' do |s|
      s.merchant.id
    end

    column 'User\'s IP' do |s|
      s.user.last_sign_in_ip
    end

    column('User Code') do |s|
      s.user.recurly_code
    end

    column('Subscription Code') do |s|
      s.recurly_code
    end
  end

  show do
    attributes_table do
      row 'User' do
        link_to(subscription.user.full_name, admin_user_path(subscription.user))
      end

      row 'Billing Info' do
        bi = subscription.user.billing_info
        "Name: #{ bi.first_name } #{ bi.last_name }<br> Card: #{ bi.card_type } ended in XXXX-XXXX-XXXX-#{ bi.last_four }, expires in #{ bi.month }/#{ bi.year }".html_safe if bi
      end

      row 'Shipping Info' do
        shipping_info_html(subscription).html_safe if subscription.shipping_info
      end

      row 'Gifting' do
        if subscription.is_gift?
          string = "Gift to: "
          string << subscription.giftee_email
          string << "(#{subscription.giftee_name})" unless subscription.giftee_name.blank?
          string << "<br> Message: #{subscription.gift_description}"
          string.html_safe
        end
      end

      row 'Created at' do
        subscription.created_at.strftime('%m/%d/%Y')
      end

      row 'Billing Status' do
        s = if subscription.active?
          'Active'
        elsif subscription.canceled?
          "Canceled at #{subscription.canceled_at.strftime('%m/%d/%Y')}"
        elsif subscription.expired?
          "Expired at #{subscription.expired_at.strftime('%m/%d/%Y')}"
        end
        if subscription.is_past_due?
          s << ' (past due)'
          s = "<span class=\"past-due\">#{s}</span>".html_safe
        end
        s.html_safe
      end

      if subscription.active?
        row 'Next renewal date' do
          subscription.renewal_date.strftime('%m/%d/%Y')
        end
      end

      row 'Merchant' do
        link_to(subscription.merchant.business_name, admin_merchant_path(subscription.merchant))
      end

      row 'Plan' do
        link_to("#{subscription.plan.name} #{subscription.plan_recurrence.shipping_desc}", admin_plan_path(subscription.plan))
      end

      row 'Base Amount' do
        "$#{subscription.plan_recurrence.amount} #{subscription.plan_recurrence.billing_desc}"
      end

      row 'Options' do
        options_html(subscription).html_safe
      end

      row 'Shipping' do
        "$ #{subscription.shipping_amount}"
      end

      row 'Taxes' do
        "$ #{subscription.recurrent_tax_amount}"
      end

      row 'Recurrent Total' do
        "$ #{subscription.recurrent_total} #{subscription.plan_recurrence.billing_desc}"
      end

      row 'Coupon' do
        coupon = subscription.coupon
        if coupon
          s = "$ #{subscription.first_time_discount} - "
          s << link_to(coupon.coupon_code, admin_coupon_path(coupon))
          s.html_safe
        end
      end

      row 'First time total' do
        "$ #{subscription.first_time_total}"
      end

      row 'Invoices and refunds' do
        s = "<ul>"
        subscription.invoices.order('created_at DESC').each do |i|
          s << "<li>#{link_to("Invoice ##{i.invoice_number}", admin_invoice_path(i))}: #{i.status} $#{i.total_in_usd.to_s} at #{i.created_at.strftime('%m/%d/%Y')}<br>"
          t = i.transactions.first
          if t
            s << "#{link_to("Refund ##{t.id}", admin_transaction_path(t))}: refunded $#{t.amount} at #{t.created_at.strftime('%m/%d/%Y')}"
          end
          s << '</li>'
        end
        s << '</ul>'
        s.html_safe
      end

      row 'Shipments' do
        if subscription.shipments.any?
          s = "<ul>"
          subscription.shipments.order('created_at DESC').each do |shipment|
            s << "<li>#{link_to("Shipment ##{shipment.id}", admin_shipment_path(shipment))}: Shipped at #{shipment.created_at.strftime('%m/%d/%Y')} via #{shipment.carrier} with tracking number '#{shipment.tracking_number}'</li>"
          end
          s << "</ul>"
          s.html_safe
        end
      end

      row 'Editions' do
        if subscription.subscription_editions.any?
          s = "<table class='subscription-editions'>"
          s << "
            <thead>
              <tr>
                <th>Applied until</th>
                <th>Plan recurrence</th>
                <th>Shipping Info</th>
                <th>Base Amount</th>
                <th>Options</th>
                <th>Shipping</th>
                <th>Taxes</th>
                <th>Recurrent Total</th>
              </tr>
            </thead>
            <tbody>
            "
          subscription.subscription_editions.order('subscription_editions.created_at ASC').each do |edition|
            s << "<tr>"
            s << "<td>#{edition.next_renewal_date}</td>"
            s << "<td>#{edition.attributes_data[:plan_recurrence]}</td>"
            if subscription.shippable?
              s << "<td>#{edition.attributes_data[:shipping_info].join(' - ')}</td>"
            else
              s << "<td>No shipping</td>"
            end
            s << "<td>$#{edition.pricing_data[:base_amount]}</td>"
            options = ""
            edition.attributes_data[:options].each do |option|
              options << "#{option}<br>"
            end
            s << "<td>#{options}</td>"
            s << "<td>$#{edition.pricing_data[:shipping_amount]}</td>"
            s << "<td>$#{edition.pricing_data[:recurrent_tax_amount]}</td>"
            s << "<td>$#{edition.pricing_data[:recurrent_total]}</td>"
            s << "</tr>"
          end

          s << "<tr class='current'>"
          s << "<td>Until next change</td>"
          s << "<td>#{subscription.plan_recurrence.shipping_desc} for #{subscription.plan_recurrence.pretty_explanation}</td>"
          s << "<td>#{subscription.shipping_info ? subscription.shipping_info.pretty_address.join(' - ') : '-'}</td>"
          s << "<td>$#{subscription.plan_recurrence.amount}</td>"
          s << "<td>#{options_html(subscription)}</td>"
          s << "<td>$#{subscription.shipping_amount}</td>"
          s << "<td>$#{subscription.recurrent_tax_amount}</td>"
          s << "<td>$#{subscription.recurrent_total}</td>"
          s << "</tr>"

          s << "</tbody></table>"
          s.html_safe
        end
      end

      row 'Monthlys commission rate' do
        "#{subscription.merchant.commission_rate} %" if subscription.merchant.commission_rate
      end

      row 'Merchant\'s first installment' do
        "#{subscription.merchant.first_installment} %" if subscription.merchant.first_installment
      end

      row 'User Recurly Code' do
        subscription.user.recurly_code
      end

      row 'Subscription Recurly Code' do
        subscription.recurly_code
      end
    end

    active_admin_comments
  end

  controller do

    include PricesHelper

    def edit
      @subscription = Subscription.find(params[:id])
      return redirect_to admin_subscription_path(@subscription), flash: { error: 'Expired subscriptions can\'t be edited.' } if @subscription.expired?

      flash.now[:success] = "Billing changes will be applied on #{@subscription.renewal_date.to_date}"

      @user = @subscription.user
      @plan = @subscription.plan
      @plan_recurrences = @plan.active_plan_recurrences
      @option_groups = @plan.active_option_groups.reject(&:onetime?)
      @shipping_infos = @user.shipping_infos.active.all
      @plan_recurrence = @subscription.plan_recurrence

      # Current totals pricing
      @totals_pricing = SubscriptionManager::TotalsPricing.totals({
        user: @subscription.user,
        plan_recurrence: @plan_recurrence,
        options: @subscription.options,
        shipping_info: @subscription.shipping_info
      })

      @options_total = @subscription.subscription_options.all.inject(0) {|total, s_o| total + (s_o.unit_amount ? (s_o.unit_amount * s_o.quantity) : 0) }

      render :edit
    end

    def update
      @subscription = Subscription.find(params[:id])
      return redirect_to admin_subscription_path(@subscription), flash: { error: 'Expired subscriptions can\'t be edited.' } if @subscription.expired?

      subscription_params = params[:subscription].slice(:shipping_info_id, :options_id, :plan_recurrence_id)
      options_id = subscription_params[:options_id].values.flatten
      plan = @subscription.plan
      plan_recurrence = plan.plan_recurrences.find_by_id(subscription_params[:plan_recurrence_id])
      shipping_info = (plan.shippable? && current_user.shipping_infos.active.find_by_id(subscription_params[:shipping_info_id])) || nil
      options = plan.options.includes(:option_group).where(id: options_id).all

      validator = SubscriptionsValidator.new({
        user: @subscription.user,
        plan: plan,
        plan_recurrence: plan_recurrence,
        shipping_info: shipping_info,
        options: options
      }, @subscription)

      if validator.valid?
        Monthly::Rapi::Subscriptions.reactivate(@subscription) if @subscription.canceled?
        Monthly::Rapi::Subscriptions.update(@subscription, {
          user: @subscription.user,
          plan: plan,
          plan_recurrence: plan_recurrence,
          shipping_info: shipping_info,
          options: options
        })
        redirect_to admin_subscription_path(@subscription), flash: { notice: 'Subscription updated successfully!' }
      else
        redirect_to edit_admin_subscription_path(@subscription), flash: { error: validator.errors }
      end
    end
  end

  member_action :reactivate, method: :put do
    @subscription = Subscription.find(params[:id])
    if @subscription.canceled?
      Monthly::Rapi::Subscriptions.reactivate(@subscription)
      redirect_to admin_subscription_path(@subscription), flash: { notice: 'Subscription reactivated!' }
    else
      redirect_to admin_subscription_path(@subscription), flash: { error: 'Subscription must be canceled to reactivate' }
    end
  end

  member_action :cancel, method: :put do
    @subscription = Subscription.find(params[:id])
    if @subscription.active?
      Monthly::Rapi::Subscriptions.cancel(@subscription)
      redirect_to admin_subscription_path(@subscription), flash: { notice: 'Subscription canceled!' }
    else
      redirect_to admin_subscription_path(@subscription), flash: { error: 'Subscription must be active to cancel' }
    end
  end

  member_action :terminate, method: :put do
    @subscription = Subscription.find(params[:id])
    if @subscription.active? || @subscription.canceled?
      refund_type = params[:refund_type]
      if %w(full none).include?(refund_type)
        Monthly::Rapi::Subscriptions.terminate(@subscription, refund_type)
        redirect_to admin_subscription_path(@subscription), flash: { notice: 'Subscription terminated!' }
      else
        redirect_to admin_subscription_path(@subscription), flash: { error: 'Wrong refund type' }
      end
    else
      redirect_to admin_subscription_path(@subscription), flash: { error: 'Subscription must be active or canceled to terminate' }
    end
  end

  member_action :refresh_totals, method: :get do
    subscription_params = params[:subscription].slice(:plan_recurrence_id, :shipping_info_id, :options_id)

    subscription = Subscription.find(params[:id])
    plan = subscription.plan
    user = subscription.user

    plan_recurrence = plan.plan_recurrences.active.find_by_id(subscription_params[:plan_recurrence_id])
    options = plan.options.where(id: subscription_params[:options_id]).all
    shipping_info = plan.shippable? ? user.shipping_infos.find_by_id(subscription_params[:shipping_info_id]) : nil

    totals_pricing = SubscriptionManager::TotalsPricing.totals({
      user: user,
      plan_recurrence: plan_recurrence,
      options: options,
      shipping_info: shipping_info
    })

    options_total = totals_pricing[:recurrent_options].inject(0) {|total, o| total + (o[:amount] ? (o[:amount] * o[:quantity]) : 0) }

    render json: {
      base_amount: pretty_price(totals_pricing[:base_amount]),
      recurrent_without_extras: pretty_price(totals_pricing[:recurrent_without_extras]),
      recurrent_shipping: totals_pricing[:recurrent_shipping] ? pretty_price(totals_pricing[:recurrent_shipping]) : nil,
      recurrent_tax: totals_pricing[:recurrent_tax] ? pretty_price(totals_pricing[:recurrent_tax]) : nil,
      billing_desc: plan_recurrence.billing_desc,
      options_total: pretty_price(options_total),
      recurrent_total: pretty_price(totals_pricing[:recurrent_total])
    }
  end

  action_item only: :show do
    String.new.tap do |content|
      unless subscription.expired?
        last_payment_amount = subscription.last_payment_amount
        full_refund_confirmation = "
          Full refund will refund the whole last paid amount.
          In this case the last payment amount was $#{last_payment_amount}.
          Subscription will also expire immediately.
          Are you sure you want to terminate and make a full refund for this subscription?
        "
        none_refund_confirmation = "
          Subscription will expire immediately.
          Are you sure you want to terminate and make no refund for this subscription?
        "
        # content << link_to('Terminate (with full refund)', terminate_admin_subscription_path(subscription, refund_type: 'full'), method: :put, confirm: full_refund_confirmation)
        content << link_to('Terminate (with no refund)', terminate_admin_subscription_path(subscription, refund_type: 'none'), method: :put, confirm: none_refund_confirmation)
      end
      if subscription.canceled?
        content << link_to('Reactivate', reactivate_admin_subscription_path(subscription), method: :put, confirm: "
          Reactivating will set this subscription as active where the user will be charged $ #{subscription.recurrent_total} on #{subscription.renewal_date}.
          Are you sure you want to reactivate?
        ")
      elsif subscription.active?
        content << link_to('Cancel', cancel_admin_subscription_path(subscription), method: :put, confirm: "
          A canceled subscription will be still shown on reports until expiration, since the user should have already paid for these services.
          Unless reactivated, this subscription will expire on #{subscription.renewal_date}.
          The user will be notified about this cancellation, are you sure you want to cancel?
        ")
      end
    end.html_safe
  end
end

# AA Helpers

def shipping_info_html(subscription)
  si = subscription.shipping_info
  "Name: #{si.first_name} #{si.last_name}<br> Address: #{si.pretty_address.join(' - ')}<br> Phone: #{si.phone}"
end

def options_html(subscription)
  options_string = ''
  subscription.options.each do |o|
    options_string << "$ #{o.amount} - #{o.option_group.description}: #{o.title}<br>"
  end.join("")
  options_string
end
