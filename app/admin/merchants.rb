ActiveAdmin.register Merchant do

  actions :index, :edit, :show, :create, :update, :new, :toggle, :reports

  filter :business_name
  filter :location

  scope :is_active
  scope :is_inactive
  scope :is_prospect

  form partial: 'form'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Merchant') do |merchant, attributes|
    attributes.merge({
      cities: merchant.cities.map {|c| { id: c.id, desc: c.name } },
      states: merchant.states.map {|s| { id: s.id, desc: s.code } },
      zipcodes: merchant.zipcodes.map {|z| { id: z.id, desc: z.number } },
      shipping_prices: merchant.shipping_prices.all.reject {|sp| !sp.percentage || sp.merchant != merchant }.map {|sp| { id: sp.id, desc: "#{sp.state.code} (#{sp.percentage})" } },
      tax_rates: merchant.tax_rates.all.reject {|tr| !tr.percentage || tr.merchant != merchant }.map {|tr| { id: tr.id, desc: "#{tr.state.code} (#{tr.percentage}%)" } },
      related_merchants: merchant.related_merchants.map {|m| { id: m.id, desc: m.business_name } },
      faqs: merchant.faqs.map {|f| { id: f.id, desc: f.question } }
    })
  end)

  member_action :toggle do
    merchant = Merchant.find(params[:id])
    if merchant.toggle(:is_active).save
      redirect_to({ action: :index }, notice: "Merchant status toggled")
    else
      redirect_to({ action: :index }, notice: merchant.errors.full_messages)
    end
  end

  sidebar :general_reports, only: :index do
    render partial: 'sidebar_index'
  end

  index do
    column :id
    column :business_name
    column :custom_site_url do |merchant|
      merchant.custom_site_url.blank? ? 'None' : link_to(merchant.custom_site_url, merchant_storefront_path(merchant.custom_site_url))
    end
    column :email
    column :is_active
    column :toggle do |merchant|
      [].tap do |actions|
        action = "De-activate" if merchant.is_active?
        action ||= "Activate"
        actions << link_to(action, toggle_admin_merchant_path(merchant))
      end.join(' ').html_safe
    end
    column 'Reports' do |merchant|
      link_to 'View Reports', reports_admin_merchant_path(merchant)
    end
    default_actions
  end

  collection_action :global_reports, :method => :get do
    @users = (0..365).to_a.reverse.map{ |day| User.where('created_at < ?', Date.today - day).count }
    @subscribers = (0..365).to_a.reverse.map{ |day| User.joins(:subscriptions).where('users.created_at < ?', Date.today - day).count }

    @users_subscribers = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      f.series(:name=>'Users',
        :data=> @users,
        :pointStart =>  365.days.ago.at_midnight.to_i * 1000,
        :pointInterval => 1.day * 1000)
      f.series(:name=>'Subscribers',
        :data => @subscribers,
        :pointStart =>  365.days.ago.at_midnight.to_i * 1000,
        :pointInterval => 1.day * 1000)
      f.options[:xAxis][:type] = :datetime
      f.options[:title][:text] = 'Users & Subscribers'
    end

    # @subscribers_merchants = LazyHighCharts::HighChart.new('graph') do |f|
    #   f.options[:chart][:defaultSeriesType] = "pie"
    #   f.series(:name=>'John', :data=>[3, 20, 3, 5, 4, 10, 12 ,3, 5,6,7,7,80,9,9])
    #   f.series(:name=>'Jane', :data=> [1, 3, 4, 3, 3, 5, 4,-46,7,8,8,9,9,0,0,9] )
    # end
  end

  member_action :reports, :method => :get do
    @merchant = Merchant.find(params[:id])
    @subscribers = (0..365).to_a.reverse.map do |day|
      User.joins(:subscriptions)
        .joins(:plans)
        .joins("JOIN merchants on merchants.id = plans.merchant_id")
        .where('users.created_at < ? AND merchants.id = ?', Date.today - day, @merchant.id).count
    end

    @subscribers = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      f.series(:name=>'Subscribers',
        :data => @subscribers,
        :pointStart =>  365.days.ago.at_midnight.to_i * 1000,
        :pointInterval => 1.day * 1000)
      f.options[:xAxis][:type] = :datetime
      f.options[:title][:text] = 'Subscribers'
    end

    @plans = Subscription.find_by_sql(['select plans.name, count(*) from subscriptions
                                      JOIN plan_recurrences on subscriptions.plan_recurrence_id = plan_recurrences.id
                                      JOIN plans ON plan_recurrences.plan_id = plans.id
                                      JOIN merchants on merchants.id = plans.merchant_id
                                      where merchants.id = ? group by plans.id, plans.name', @merchant.id])

    @plans_chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "bar"
      f.series(:name=>'Plans',
        :data => @plans.map{|x| x.count.to_i})
      f.options[:xAxis][:categories] = @plans.map(&:name)
      f.options[:title][:text] = 'Subscribers'
    end
  end

  show do
    attributes_table do
      if merchant.is_prospect?
        row :business_name
        row :contact_name
        row :contact_last_name
        row :email
        row :business_type
        row :website
        row :comments
        row :phone
        row :address1
        row :address2
        row :zipcode
        row :city
        row :state
        row :country
      else
        row :business_name
        row :marketing_phrase
        row :commission_rate
        row :first_installment
        row :cutoff_day do
          "Every #{merchant.cutoff_day}"
        end
        row :email
        row :contact_name
        row :contact_last_name
        row :phone
        row :website
        row :is_active
        row :terms_of_service
        row :address1
        row :address2
        row :zipcode
        row :city
        row :state
        row :country
        row :show_location
        row :custom_message_type do
          case merchant.custom_message_type
          when :none then 'Don\'t allow gift messages.'
          when :shipment_message then 'Allow message on shipment and gift emails.'
          when :monthlys_message then 'Do not allow message on shipment, but allow gift emails.'
          end
        end
        row :area_of_service_availability do
          if merchant.nationwide?
            "Nationwide"
          elsif merchant.state_list?
            "In the following states: #{merchant.states.map(&:to_s).to_sentence}"
          elsif merchant.city_list?
            "In the following cities: #{merchant.cities.map(&:to_s).to_sentence}"
          elsif merchant.zipcode_list?
            "In the following zipcodes: #{merchant.zipcodes.map(&:number).to_sentence}"
          end
        end
        row :shipping_prices do
          if merchant.shipping_type == 'state_dependant'
            ("<span>State Dependant</span>" + \
             "<ul>" + \
              merchant.shipping_prices.select{|sp| !sp.percentage.blank? }.map {|sp| "<li>#{sp.state.code} (#{sp.percentage}%)</li>" }.join(' ') + \
              "</ul>").html_safe
          elsif merchant.shipping_type == 'flat_rate'
            "Flat rate: $#{merchant.shipping_rate}"
          else
            "Free"
          end
        end
        row :tax_rates do
          ("<ul>" + \
          merchant.tax_rates.select{|tr| !tr.percentage.blank? }.map {|tr| "<li>#{tr.state.code} (#{tr.percentage}%)</li>" }.join(' ') + \
          "</ul>").html_safe
        end
      end
    end
    active_admin_comments
  end

  controller do
    def new
      @merchant = Merchant.new
      @merchant.shipping_type = 'free'
      State.order('states.code').all.each {|state| @merchant.shipping_prices.new({ state_id: state.id }) }
      State.order('states.code').all.each {|state| @merchant.tax_rates.new({ state_id: state.id }) }
    end

    def create
      @merchant = Merchant.new(params[:merchant])
      if @merchant.save
        redirect_to admin_merchants_path, flash: { notice: 'Merchant was saved successfully' }
      else
        flash.now[:error] = @merchant.errors.full_messages
        render :new
      end
    end

    def show
      @merchant = Merchant.find(params[:id])
    end

    def edit
      @merchant = Merchant.find(params[:id])
      if @merchant.shipping_prices.empty?
        State.order('states.code').all.each {|state| @merchant.shipping_prices.new({ state_id: state.id }) }
      end
      if @merchant.tax_rates.empty?
        State.order('states.code').all.each {|state| @merchant.tax_rates.new({ state_id: state.id }) }
      end
    end

    def update
      @merchant = Merchant.find(params[:id])
      if @merchant.update_attributes(params[:merchant])
        redirect_to admin_merchants_path, flash: { notice: 'Merchant updated successfully' }
      else
        flash.now[:error] = @merchant.errors.full_messages
        render :edit
      end
    end
  end
end
