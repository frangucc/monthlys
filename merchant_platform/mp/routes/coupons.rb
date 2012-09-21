require mp_path('mp/forms/coupons')

module MP
  module Routes
    CouponsResource = MP::Routes::Generic::resource_factory(
      resource_name: :coupon,
      base_url: '/coupon',
      model_class: Coupon,
      template_path: 'coupons',
      form_class: MP::Forms::CouponForm
    )

    class Coupons < CouponsResource
      register Generic::ResourceListRoutes
      register Generic::ResourceNewRoutes
      register Generic::ResourceEditRoutes

      def authorize!
        admin_required!
      end
    end
  end

  Main.use Routes::Coupons
end
