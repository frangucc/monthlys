require mp_path('mp/forms/merchants')

module MP
  module Routes
    StoreFrontResource = MP::Routes::Generic::resource_factory(
      resource_name: :storefront,
      base_url: '/storefront',
      model_class: Merchant,
      template_path: 'storefronts',
      form_class: MP::Forms::StoreFront,
      edit_redirect_path: :storefront_edit_redirect
    )

    class StoreFronts < StoreFrontResource
      get url(:storefront_edit_redirect, '/storefront/edit/') do
        authorize!
        redirect url_for(:storefront_edit, id: current_merchant.id)
      end

      register Generic::ResourceEditRoutes
    end
  end

  Main.use Routes::StoreFronts
end
