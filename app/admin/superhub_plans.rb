ActiveAdmin.register SuperhubPlan do
  menu parent: 'Navigation', label: 'Superhub Plans'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('SuperhubPlan') do |superhub_plan, attributes|
    attributes.delete(:plan_id)
    attributes.delete(:superhub_plan_group_id)
    attributes.merge({
      plan: superhub_plan.plan ? { id: superhub_plan.plan_id, desc: superhub_plan.plan.name } : nil,
      superhub_plan_group: superhub_plan.superhub_plan_group ? { id: superhub_plan.superhub_plan_group_id, desc: superhub_plan.superhub_plan_group.title } : nil
    })
  end)

  filter :superhub_plan_group, collection: (Proc.new do
    Hash[ SuperhubPlanGroup.all.map do |pg|
      ["#{Superhub.new(pg.superhub).verbose_name} - #{pg.title}", pg.id]
    end ]
  end)
  filter :plan

  index do
    column :id
    column :plan
    column :superhub_plan_group
    column :superhub do |sp|
      Superhub.new(sp.superhub_plan_group.superhub).verbose_name
    end
    column :superhub_group_title do |sp|
      sp.superhub_plan_group.title
    end
    column :ordering
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :superhub do |sp|
        Superhub.new(sp.superhub_plan_group.superhub).verbose_name
      end
      row :superhub_group_title do |sp|
        sp.superhub_plan_group.title
      end
      row :plan
      row :title
      row :subtitle
      row :ordering
      row :image do |sp|
        (sp.image.blank?) ? '' : image_tag(sp.image.url)
      end
      row :video_url
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'Details' do
      f.input :superhub_plan_group, as: :select, required: true,
              collection: SuperhubPlanGroup.order(:superhub).all,
              member_label: Proc.new { |pg| "#{Superhub.new(pg.superhub).verbose_name} - #{pg.title}" }
      f.input :plan, required: true, collection: Plan.order(:name)
      f.input :title
      f.input :subtitle
      f.input :ordering, required: true
      f.input :image
      f.input :video_url
    end
    f.buttons
  end
end
