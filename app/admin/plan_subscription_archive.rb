ActiveAdmin.register PlanSubscriptionArchive do
  menu parent: 'Plans', label: 'Subscription archive'
#
#  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('SuperhubPlan') do |superhub_plan, attributes|
#    attributes.delete(:plan_id)
#    attributes.delete(:superhub_plan_group_id)
#    attributes.merge({
#      plan: superhub_plan.plan ? { id: superhub_plan.plan_id, desc: superhub_plan.plan.name } : nil,
#      superhub_plan_group: superhub_plan.superhub_plan_group ? { id: superhub_plan.superhub_plan_group_id, desc: superhub_plan.superhub_plan_group.title } : nil
#    })
#  end)

  filter :plan
  filter :sent_on

  index do
    column :id
    column :sent_on
    column :plan
    column :title
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :plan
      row :sent_on
      row :title
      row :image do |psa|
        (psa.image.blank?) ? '' : image_tag(psa.image.url)
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
