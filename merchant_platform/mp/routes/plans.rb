require mp_path('mp/forms/plans.rb')


module MP
  module Routes
    PlansResource = MP::Routes::Generic::resource_factory(
      resource_name: :plan,
      base_url: '/plans',
      model_class: Plan,
      template_path: 'plans',
      form_class: MP::Forms::Plan
    )

    class Plans < PlansResource
      # Generic routes and overrides

      register Generic::ResourceListRoutes
      register Generic::ResourceNewRoutes
      register Generic::ResourceEditRoutes
      register Generic::ResourceDeleteRoutes


      def dataset
        current_merchant.plans.order(:id)
      end

      def new_context_hook(ctx)
        ctx.merge({ types: PlanType.subtypes_by_types() })
      end
      alias_method(:edit_context_hook, :new_context_hook)


      # Other routes

      get url(:categories, '/categories/') do
        authorize!

        filter_ids = params.fetch('ids', nil)
        filter_ids = params['ids'].split(',').map(&:to_i) if filter_ids

        categories = Category.where('name ILIKE ?', "%#{params[:name]}%")
        if filter_ids
          categories = categories.where('id in (?)', filter_ids)
        end

        json(categories.map{ |c| { id: c.id, name: c.name } })
      end
    end
  end

  Main.use Routes::Plans
end
