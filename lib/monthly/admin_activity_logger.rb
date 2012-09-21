module Monthly
  module AdminActivityLogger

    USELESS_ATTRIBUTES = [:created_at, :updated_at]

    module_function

    def get_around_filter_block_for(klass_name, options = {})
      klass = Kernel.const_get(klass_name)

      instance_var_name = options.fetch(:instance_var_name, klass_name.underscore)
      find_by = options.fetch(:find_by, 'id')
      possible_actions = %w(create update destroy sync) + options.fetch(:extra_actions, [])

      Proc.new do |controller, action| # This is the around filter
        if possible_actions.include?(controller.action_name)
          before_resource = instance_variable_get("@#{instance_var_name}") || (controller.action_name == 'create' ? klass.new : klass.send("find_by_#{find_by}", params[:id]))

          return head :not_found unless before_resource

          before_attributes = Monthly::AdminActivityLogger.reject_useless_attributes(before_resource.attributes.dup.symbolize_keys)
          before_attributes = yield(before_resource, before_attributes) if block_given?

          action.call

          after_resource = instance_variable_get("@#{instance_var_name}")
          after_attributes = Monthly::AdminActivityLogger.reject_useless_attributes(after_resource.attributes.dup.symbolize_keys)
          after_attributes = yield(after_resource, after_attributes) if block_given?

          unless after_resource.new_record? || after_resource.changed?
            AdminActivity.create!(
              verb: controller.action_name,
              admin_user: current_admin_user,
              object: after_resource,
              previous_attributes: before_attributes,
              new_attributes: after_attributes
            )
          end
        else # Skipping the admin_user save for the rest of the actions
          action.call
        end
      end
    end

    def reject_useless_attributes(attributes)
      USELESS_ATTRIBUTES.each do |attribute|
        attributes.delete(attribute)
      end

      attributes
    end
  end
end
