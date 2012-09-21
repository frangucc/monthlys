require mp_path('mp/forms/cities')

module MP
  module Routes
    CityResource = MP::Routes::Generic::resource_factory(
      resource_name: :city,
      base_url: '/city',
      model_class: City,
      template_path: 'cities',
      form_class: MP::Forms::CityForm,
      resource_name_plural: :cities
    )

    class Cities < CityResource
      register Generic::ResourceListRoutes
      register Generic::ResourceNewRoutes
      register Generic::ResourceEditRoutes

      def authorize!
        admin_required!
      end
    end
  end

  Main.use Routes::Cities
end
