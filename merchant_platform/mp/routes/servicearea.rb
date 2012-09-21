module MP
  module Routes
    ServiceAreaResource = MP::Routes::Generic::resource_factory(
      resource_name: :servicearea,
      base_url: '/servicearea',
      model_class: Merchant,
      template_path: 'servicearea',
      form_class: MP::Forms::ServiceArea,
      edit_redirect_path: :servicearea_edit_redirect
    )

    class ServiceArea < ServiceAreaResource
      get url(:servicearea_edit_redirect, '/servicearea/edit/') do
        authorize!
        redirect url_for(:servicearea_edit, id: current_merchant.id)
      end

      register Generic::ResourceEditRoutes
    end
  end

  Main.use Routes::ServiceArea
end
