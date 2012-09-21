require mp_path('mp/forms/merchants')

module MP
  module Routes
    MarketingResource = MP::Routes::Generic::resource_factory(
      resource_name: :marketing,
      base_url: '/marketing',
      model_class: Merchant,
      template_path: 'marketing',
      form_class: MP::Forms::Marketing,
      edit_redirect_path: :marketing_edit_redirect
    )

    class Marketing < MarketingResource
      get url(:marketing_edit_redirect, '/marketing/edit/') do
        authorize!
        redirect url_for(:marketing_edit, id: current_merchant.id)
      end

      register Generic::ResourceEditRoutes
    end
  end

  Main.use Routes::Marketing
end
