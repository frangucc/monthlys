ActiveAdmin.register Option do

  menu parent: 'Plans'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Option') do |option, attributes|
    attributes.delete(:option_group_id)
    attributes.merge({
      option_group: option.option_group ? { id: option.option_group_id, desc: option.option_group.description } : nil
    })
  end)

  filter :option_group, collection: proc { OptionGroup.order(:description).all }
  filter :title
  filter :description
  filter :is_active, as: :select

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs do
      f.input :option_group, label: "Option Group / Question"
      f.input :title, label: "Answer"
      f.input :order
      f.input :description
      f.input :invoice_description, hint: 'Text to show in the invoice next to the amount to be paid. It needs to be a really brief.'
      f.input :amount, as: :string, hint: "Depends on the option group's impact on the price. <br />
        This amount will have no effect for 'No Charge' option groups. <br />
        This amount will be charged only the first time for 'One Time Fee' optiongroups. <br />
        This amount will be charged every billing cycle for 'Recurring amount per service' option groups.".html_safe
      f.input :image, as: :file, hint: 'Master image ideal size: 130x85px'
      if f.object.new_record?
        f.input :is_active, :input_html => { :checked => 'checked' }
      else
        f.input :is_active
      end
    end
    f.buttons
  end

  # Overriding AA Plan Controller
  # Prevent the admin user from deleting modifying a option associated
  # with a subscription and sync plan with recurly after
  # creating/updating options.
  controller do
    def create
      @option = Option.new(params[:option])
      if @option.save
        Monthly::Rapi::Plans.sync(@option.plan)
        redirect_to(admin_options_path,
                    flash: { notice: 'Option was saved successfully' })
      else
        flash.now[:error] = @option.errors.full_messages
        render :new
      end
    end

    def update
      @option = Option.find(params[:id])
      @option.attributes = params[:option]

      do_sync = recurly_sync_needed?(@option) # This must be called before save
      if can_update?(@option)
        if @option.save
          Monthly::Rapi::Plans.sync(@option.plan) if do_sync
          redirect_to(admin_option_path(@option.id),
                      flash: { notice: 'Option updated successfully' })
        else
          flash.now[:error] = @option.errors.full_messages
          render :edit
        end
      else
        redirect_to admin_option_path(@option.id), flash: { error: '
          This Option has a subscription associated, so it can\'t be updated.
          You may create a new one and mark this Option as inactive instead.'
        }
      end
    end

    def destroy
      @option = Option.find(params[:id])
      if has_associated_subscription?
        redirect_to admin_option_path(@option.id), flash: { error: '
          This Option has a subscription associated, so it can\'t be deleted.
          You may mark it as inactive instead. Non modifyable attributes are: amount, option group and title.'
        }
      else
        @option.destroy
        redirect_to admin_options_path, flash: { notice: 'Option deleted successfully' }
      end
    end

    def recurly_sync_needed?(option)
      rfields = [ :amount, :option_group_id, :title ]
      rfields.any? { |f| option.send("#{f}_changed?") }
    end

    def has_associated_subscription?
      Subscription.includes(:options).where(options: { id: @option.id }).any?
    end

    def can_update?(option)
      fields = [ :amount, :option_group_id, :title ]
      !(fields.any? { |f| option.send("#{f}_changed?") } && has_associated_subscription?)
    end
  end
end
