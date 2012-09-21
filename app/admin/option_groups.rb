ActiveAdmin.register OptionGroup do

  menu parent: 'Plans'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('OptionGroup') do |option_group, attributes|
    attributes.delete(:plan_id)
    attributes.merge({
      plan: option_group.plan ? { id: option_group.plan_id, desc: option_group.plan.name } : nil
    })
  end)

  index do
    column :id
    column :plan
    column :description
    column :option_type
    column :allow_multiple
    column :is_active
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :plan, as: :select, collection: Plan.order("name ASC").all, include_blank: false
      f.input :order
      f.input :description, label: "Question"
      f.input :allow_multiple, label: "Allow multiple answers"
      f.input :option_type, label: "Impact on the price", as: :select, collection: [['No charge', :nocharge], ['One time fee', :onetime], ['Recurring amount per service', :per_service], ['Recurring amount per billing cycle', 'per_billing']], include_blank: false
      if f.object.new_record?
        f.input :is_active, :input_html => { :checked => 'checked' }
      else
        f.input :is_active
      end
    end
    f.buttons
  end

  # Overriding AA Plan Controller
  # Prevent the admin user from deleting modifying a option_group associated with a subscription.
  controller do
    def update
      @option_group = OptionGroup.find(params[:id])
      @option_group.attributes = params[:option_group]

      do_sync = recurly_sync_needed?(@option_group) # This must be called before save
      if can_update?(@option_group)
        if @option_group.save
          Monthly::Rapi::Plans.sync(@option_group.plan) if do_sync
          redirect_to(admin_option_group_path(@option_group.id),
                      flash: { notice: 'Option Group updated successfully' })
        else
          flash.now[:error] = @option_group.errors.full_messages
          render :edit
        end
      else
        redirect_to admin_option_group_path(@option_group.id), flash: { error: '
          This Option Group has a subscription associated, so it can\'t be updated.
          You may create a new one and mark this Option Group as inactive instead.'
        }
      end
    end

    def destroy
      @option_group = OptionGroup.find(params[:id])
      if has_associated_subscription?
        redirect_to admin_option_group_path(@option_group.id), flash: { error: '
          This Option Group has a subscription associated, so it can\'t be deleted.
          You may mark it as inactive instead.'
        }
      else
        @option_group.destroy
        Monthly::Rapi::Plans.sync(@option_group.plan)
        redirect_to admin_option_groups_path, flash: { notice: 'Option Group deleted successfully' }
      end
    end

    def recurly_sync_needed?(og)
      rfields = [ :plan_id, :option_type, :description ]
      rfields.any? { |f| og.send("#{f}_changed?") } && og.options.any?
    end

    def has_associated_subscription?
      Subscription.includes(options: :option_group).where(options: { option_group_id: @option_group.id }).any?
    end

    def can_update?(og)
      fields = [ :plan_id, :option_type, :description, :allow_multiple ]
      !(fields.any? { |f| og.send("#{f}_changed?") } && has_associated_subscription?)
    end
  end
end
