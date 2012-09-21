require mp_path('mp/forms/merchants')

module MP
  module Routes
    MerchantResource = MP::Routes::Generic::resource_factory(
      resource_name: :merchant,
      base_url: '/merchant',
      model_class: Merchant,
      template_path: 'merchants',
      form_class: MP::Forms::BusinessInformation,
      edit_redirect_path: :merchant_edit_redirect
    )

    class Merchants < MerchantResource
      get url(:merchant_edit_redirect, '/merchant/edit/') do
        authorize!
        redirect url_for(:merchant_edit, id: current_merchant.id)
      end

      register Generic::ResourceEditRoutes
    end
  end

  Main.use Routes::Merchants
end
