class SuperhubsController < ApplicationController
  def show
    begin
      @superhub = Superhub.new(params.fetch(:id))
    rescue KeyError
      not_found
    end
    superhub_plan_groups = SuperhubPlanGroup
      .where(superhub: @superhub.key)
      .includes(:superhub_plans)
      .order(:ordering).all

    @groups = superhub_plan_groups.map do |superhub_plan_group|
      group_plans_scope = superhub_plan_group.superhub_plans.order('RANDOM()')

      group_plans = if Monthly::Application.config.app_config.localized_superhubs_list.include?(@superhub.key)
        superhub_plans = group_plans_scope.all
        all_plans_id = superhub_plans.map(&:plan_id)
        available_plans_id = geocoder_service.filter_plans_by_location(Plan.where(id: all_plans_id)).select('plans.id').map(&:id)
        superhub_plans.select {|shp| available_plans_id.include?(shp.plan_id) }
      else
        group_plans_scope.all
      end

      {
        title: superhub_plan_group.title,
        subtitle: superhub_plan_group.subtitle,
        group_type: superhub_plan_group.group_type,
        label: superhub_plan_group.label.blank? ? nil : superhub_plan_group.label,
        label_display: superhub_plan_group.label.blank? ? nil : superhub_plan_group.get_label_display,
        superhub_plans: group_plans
      }
    end

    load_sidebar_categories
  end
end
