ActiveAdmin.register Coupon do

  menu parent: 'Marketing'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Coupon') do |coupon, attributes|
                    attributes.merge({ plans: coupon.plans.map {|p| { id: p.id, desc: p.name } } })
                  end)
  scope :available_to_all_plans
  scope :available_to_selected_plans
  scope :eversave
  scope :totsy

  index do
    column :id
    column :coupon_code
    column :name
    column :discount do |coupon|
      coupon.pretty_discount
    end
    column :plans do |coupon|
      coupon.plans.map{ |p| link_to p.name, plan_path(p) }.to_sentence.html_safe
    end
    column :max_redemptions
    column :is_active

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :coupon_code
      f.input :name
      f.input :marketing_description
      f.input :invoice_description, hint: 'Will be displayed on the checkout and the user\'s invoice.'
      f.input :image
      f.input :redeem_by_date
      f.input :applies_for_months
      f.input :max_redemptions
      f.input :discount_type, as: :select, collection: [['Percentage', 'percent'], ['Amount in dollars', 'dollars']], include_blank: false
      f.input :discount_percent
      f.input :discount_in_usd
      # f.input :single_use # Non single-use coupons are not supported yet.
      f.input :available_to_all_users, hint: 'If you enable this option, this coupon will be instantly available to all users who know the coupon code'
      f.input :applies_to_all_plans
      f.input :is_active
      f.input :plans, as: :select, hint: 'Select plans, only if this coupon doesn\'t Apply to all plans'
    end
    f.buttons
  end

  show do |coupon|
    attributes_table do
      row :coupon_code
      row :name
      row :marketing_description
      row :invoice_description
      row :redeem_by_date do
        coupon.redeem_by_date || 'Does not redeeem'
      end
      row :single_use
      row :applies_for_months do
        !! coupon.applies_for_months
      end
      row :max_redemptions do
        if coupon.max_redemptions
          "#{coupon.max_redemptions} (#{coupon.redemptions.count} used)"
        else
          'No limit'
        end
      end
      row :applies_to_all_plans
      unless coupon.applies_to_all_plans
        row :plans do
          coupon.plans.map(&:name).to_sentence
        end
      end
      row :available_to_all_users
      row :discount do
        coupon.pretty_discount
      end
      row :is_active
      row :image do
        coupon.image? && image_tag(coupon.image.url)
      end
    end
  end

  csv do
    column :coupon_code
  end

  # Overriding AA Coupon Controller
  controller do
    def create
      @coupon = Coupon.new(params[:coupon])
      @coupon.single_use = true
      if @coupon.save
        redirect_to admin_coupons_path, flash: { notice: 'Coupon was saved successfully' }
        Monthly::Rapi::Coupons.sync(@coupon)
      else
        flash.now[:error] = @coupon.errors.full_messages
        render :new
      end
    end

    def update
      @coupon = Coupon.find(params[:id])
      @coupon.attributes = params[:coupon]

      do_sync = recurly_sync_needed?(@coupon) # This must be called before save
      if @coupon.save
        Monthly::Rapi::Coupons.sync(@coupon) if do_sync
        redirect_to(admin_coupon_path,
                    flash: { notice: 'Coupon updated successfully' })
      else
        flash.now[:error] = @coupon.errors.full_messages
        render :edit
      end
    end

    def recurly_sync_needed?(coupon)
      rfields = [ :coupon_code, :name, :invoice_description,
                  :redeem_by_date, :single_use, :applies_for_months,
                  :max_redemptions, :applies_to_all_plans, :discount_type,
                  :discount_percent, :discount_in_usd ]
      rfields.any? { |f| coupon.send("#{f}_changed?") }
    end
  end
end
