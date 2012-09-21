ActiveAdmin.register Plan do

  actions :index, :show, :edit, :update, :new, :create, :sync

  form partial: 'form'

  member_action :sync, method: :get

  filter :name
  filter :status, as: :select, collection: [:active, :inactive, :pending]
  filter :merchant, as: :select, collection: proc { Merchant.order('merchants.business_name ASC').all }

  before_filter only: [:show, :edit] do
    @plan = Plan.find_by_slug(params[:id])
  end

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Plan', { find_by: 'slug' }) do |plan, attributes|
    attributes.merge({
      categories: plan.categories.map {|c| { id: c.id, desc: c.name } },
      tags: plan.tags.map {|t| { id: t.id, desc: t.keyword } },
      attachments: plan.attachments.map {|a| { id: a.id, desc: a.image.to_s } }
    })
  end)

  index do
    column :id
    column :name
    column :status
    column 'Merchant', sortable: false do |plan|
      link_to plan.merchant.business_name, admin_merchant_path(plan.merchant)
    end
    column '# Recurrences', sortable: false do |plan|
      plan.plan_recurrences.count
    end
    column 'Actions' do |plan|
      [].tap do |actions|
        actions << link_to('View', admin_plan_path(plan))
        actions << link_to('Edit', edit_admin_plan_path(plan))
        actions << link_to('Sync with Recurly', sync_admin_plan_path(plan), class: "recurly-sync-btn")
      end.join(' ').html_safe
    end
  end

  show do
    attributes_table do
      # Name and status
      row :id
      row :name
      row :status do
        (plan.status == 'pending')? "#{plan.status} (#{link_to 'View', preview_plan_path(plan.unique_hash)})".html_safe : plan.status
      end

      # Plan recurrences and options
      row :active_plan_recurrences do
        if plan.plan_recurrences.active.any?
          (ul { plan.plan_recurrences.each {|pr| li link_to(pr.pretty_explanation, admin_plan_recurrence_path(pr), class: "#{ (pr.is_active == true) ? 'active' : 'inactive' }") } })
        else
          'None'
        end
      end

      row :active_options do
        og_content = "<ul>"
        if plan.active_option_groups.any?
          plan.active_option_groups.map do |og|
            og_content << "<li>#{og.description} - (Impact on the price: #{og.option_type}. Allow multiple: #{og.allow_multiple}.)<ul>"
              og.options.active.each do |o|
                og_content << "<li> #{link_to o.title, admin_options_path(o) }</li>"
              end
            og_content << '</ul></li>'
            og_content.html_safe
          end.join('')
        end
        og_content << "</ul>"
        og_content.html_safe
      end

      # Shippable
      row :is_shippable do
        plan.shippable?
      end
      row :type do
        plan.subtype_str
      end

      # Merchant
      row :merchant do
        link_to(plan.merchant.business_name, admin_merchant_path(plan.merchant))
      end
      row :merchant_delivery_area do
        plan.merchant.delivery_area_description
      end
      row :merchant_shipping_costs do
        plan.merchant.shipping_cost_description
      end
      row :merchant_taxation_policies do
        plan.merchant.taxation_policy
      end

      # Descriptions
      row :categories do
        plan.categories.map(&:name).join(', ')
      end
      row :marketing_phrase
      row :short_description
      row :notes_to_customer

      # Subscription Count
      row :subscriptions_count do
        "Initial: #{plan.initial_count}. Real subscriptions: #{plan.subscriptions.count}. Total: #{plan.subscriptions_count}."
      end

      # Images
      row :icon do
        image_tag(plan.icon.url, alt: plan.name)
      end
      row :thumbnail do
        image_tag(plan.thumbnail.url, alt: plan.name)
      end
      row :images do
        plan.attachments.map {|a| link_to admin_attachment_path(a) do image_tag(a.image.url) end }.join('<br/>').html_safe
      end
    end
  end

  csv do
    column :id
    column ('name') do |p|
      p.name.gsub(/\,/, ' ')
    end
    column ('description') do |p|
      #p.marketing_phrase || p.description
      (p.marketing_phrase || p.description).gsub(/\,/, ' ')
    end
    column ('price') do |p|
      unless p.cheapest_plan_recurrence.nil?
        "$ #{sprintf('%.02f', p.cheapest_plan_recurrence.amount)}"
      else
        ''
      end
    end
    column ('taxes') do |p|
      unless p.cheapest_plan_recurrence.nil?
        "$ #{sprintf('%.02f', p.cheapest_plan_recurrence.amount * p.tax_factor_in_IL )}"
      else
        ''
      end
    end
    column 'shipping' do
      '$0'
    end
    column 'condition' do
      'new'
    end
    column ('link') do |p|
      plan_url(p)
    end
    column 'availability' do
      'in stock'
    end
    column('image_link') do |p|
      if p.attachments.any?
        p.attachments.first.image
      else
        ''
      end
    end
  end

  # Overriding AA Plan Controller
  controller do
    def create
      images = params[:plan].delete(:images) || []
      @plan = Plan.new(params[:plan])
      images.each { |image| @plan.attachments.new(image: image) }
      if @plan.save
        redirect_to admin_plans_path, flash: { notice: 'Plan was saved successfully' }
      else
        flash.now[:error] = @plan.errors.full_messages
        render :new
      end
    end

    def update
      images = params[:plan].delete(:images) || []

      @plan = Plan.find_by_slug(params[:id])
      @plan.attributes = params[:plan]

      images.each { |image| @plan.attachments.new({ image: image }) }

      do_sync = recurly_sync_needed?(@plan) # This must be called before save
      if @plan.plan_type.to_s != params[:plan][:plan_type] && has_associated_subscriptions?
        flash.now[:error] = 'Can\' t modify the plan type of a plan with subscriptions associated to it. You may create a new plan instead.'
        render :edit
      elsif @plan.save
        Monthly::Rapi::Plans.sync(@plan) if do_sync
        redirect_to admin_plans_path, flash: { notice: 'Plan updated successfully' }
      else
        flash.now[:error] = @plan.errors.full_messages
        render :edit
      end
    end

    def sync
      @plan = Plan.find_by_slug(params[:id])
      if @plan.plan_recurrences.any?
        Monthly::Rapi::Plans.sync(@plan)
        @plan.coupons.each do |coupon|
          Monthly::Rapi::Coupons.sync(coupon) unless coupon.expired?
        end
        redirect_to admin_plans_path, flash: { notice: "Plan synchronized with Recurly successfully!" }
      else
        redirect_to admin_plans_path, flash: { error: "You must have at least 1 plan recurrence to sync with Recurly." }
      end
    end

    def has_associated_subscriptions?
      @plan.subscriptions.any?
    end

    def recurly_sync_needed?(plan)
      rfields = [ :name ]
      rfields.any? { |f| plan.send("#{f}_changed?") } && plan.plan_recurrences.any?
    end
  end
end
