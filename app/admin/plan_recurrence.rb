ActiveAdmin.register PlanRecurrence do

  menu parent: 'Plans'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('PlanRecurrence') do |plan_recurrence, attributes|
    attributes.delete(:option_group_id)
    attributes.merge({
      plan: plan_recurrence.plan ? { id: plan_recurrence.plan_id, desc: plan_recurrence.plan.name } : nil
    })
  end)

  filter :plan, as: :select, collection: proc { Plan.order(:name).all }
  filter :amount
  filter :is_active, as: :select

  index do
    column :id
    column :is_active
    column :plan
    column :amount
    column "Recurrence type" do |pr|
      Recurrence.get(pr.recurrence_type)[:name] unless pr.recurrence_type.blank?
    end
    column :monthly_cost do |pr|
      pr.monthly_cost
    end
    column :service_cost do |pr|
      pr.service_cost
    end
    default_actions
  end

  show do
    dl do
      dt "Plan"
      if plan_recurrence.plan
        dd link_to(plan_recurrence.plan.name, admin_plan_path(plan_recurrence.plan))
      else
        dd "No plan!"
      end
      dt "Status"
      dd plan_recurrence.status || "Inactive"
      dt "Old Amount"
      dd plan_recurrence.fake_amount
      dt "Current Amount"
      dd plan_recurrence.amount
      dt "Recurrence Type"
      if plan_recurrence.recurrence_type.blank?
        dd "No recurrence type!"
      else
        dd Recurrence.get(plan_recurrence.recurrence_type)[:name]
      end
      dt "Is Active"
      dd plan_recurrence.is_active?
    end
  end

  form do |f|
    f.inputs "General" do
      f.input :plan, as: :select, collection: Plan.order("name ASC").all, include_blank: false
      f.input :fake_amount, as: :string, label: 'Old Amount', hint: "This amount will not be taken into account, it will just show up on the plan detail striked through. Fill only for plans meant to be 'on sale'. Please note you need to edit all the plan recurrences of a specific plan for this to make sense."
      f.input :amount, as: :string, required: true, label: 'Current Amount', hint: "Real amount to be charged. Format: 100.00"
      f.input :recurrence_type, as: :select, collection: Recurrence.recurrence_types, include_blank: false
      if f.object.new_record?
        f.input :is_active, :input_html => { :checked => 'checked' }
      else
        f.input :is_active
      end
    end
    f.buttons
  end

  # Overriding AA Plan Controller
  # Prevent the admin user from deleting modifying a plan_recurrence
  # associated with a subscription and sync plan with recurly after
  # creating/updating plan recurrences.
  controller do
    def create
      @plan_recurrence = PlanRecurrence.new(params[:plan_recurrence])
      if @plan_recurrence.save
        Monthly::Rapi::Plans.sync(@plan_recurrence.plan)
        redirect_to(admin_plan_recurrences_path,
                    flash: { notice: 'Plan recurrence was saved successfully' })
      else
        flash.now[:error] = @plan_recurrence.errors.full_messages
        render :new
      end
    end

    def update
      @plan_recurrence = PlanRecurrence.find(params[:id])
      @plan_recurrence.attributes = params[:plan_recurrence]

      do_sync = recurly_sync_needed?(@plan_recurrence) # This must be called before save
      if @plan_recurrence.is_active_changed? && last_active_plan_recurrence?
        redirect_to admin_plan_recurrence_path(@plan_recurrence), flash: { error: "
          This plan recurrence can't be inactivated as it's the last active plan recurrence for #{@plan_recurrence.plan.name}.
          To disable this one, please create another plan recurrence for this plan and try again."
        }
      elsif can_update?(@plan_recurrence)
        if @plan_recurrence.save
          Monthly::Rapi::Plans.sync(@plan_recurrence.plan) if do_sync
          redirect_to(admin_plan_recurrence_path(@plan_recurrence.id),
                      flash: { notice: 'Plan Recurrence updated successfully' })
        else
          flash.now[:error] = @plan_recurrence.errors.full_messages
          render :edit
        end
      else
        redirect_to admin_plan_recurrence_path(@plan_recurrence.id), flash: { error: '
          This Plan Recurrence has a subscription associated, so it can\'t be updated.
          You may create a new one and mark this Plan Recurrence as inactive instead.'
        }
      end
    end

    def destroy
      @plan_recurrence = PlanRecurrence.find(params[:id])
      if has_associated_subscription?
        redirect_to admin_plan_recurrence_path(@plan_recurrence), flash: { error: '
          This Plan Recurrence has a subscription associated, so it can\'t be deleted.
          You may mark it as inactive instead. Non modifyable attributes are amount, plan and recurrence type.'
        }
      elsif @plan_recurrence.is_active? && last_active_plan_recurrence?
        redirect_to admin_plan_recurrence_path(@plan_recurrence), flash: { error: "
          This plan recurrence can't be deleted as it's the last active plan recurrence for #{@plan_recurrence.plan.name}.
          To disable this one, please create another plan recurrence for that plan and try again."
        }
      else
        @plan_recurrence.destroy
        Monthly::Rapi::Plans.sync(@plan_recurrence.plan)
        redirect_to admin_plan_recurrences_path, flash: { notice: 'Plan Recurrence deleted successfully' }
      end
    end

    def recurly_sync_needed?(pr)
      rfields = [ :amount, :plan_id, :recurrence_type ]
      rfields.any? { |f| pr.send("#{f}_changed?") }
    end


    def has_associated_subscription?
      Subscription.where(plan_recurrence_id: @plan_recurrence.id).any?
    end

    def last_active_plan_recurrence?
      PlanRecurrence.active.where(plan_id: @plan_recurrence.plan_id).where('id != ?', @plan_recurrence.id).empty?
    end

    def can_update?(pr)
      fields = [ :amount, :plan_id, :recurrence_type ]
      !(fields.any? { |f| pr.send("#{f}_changed?") } && has_associated_subscription?)
    end
  end
end
