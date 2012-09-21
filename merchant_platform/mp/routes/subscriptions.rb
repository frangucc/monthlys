module MP
  module Routes
    SubscriptionResource = MP::Routes::Generic::resource_factory(
      resource_name: :subscription,
      base_url: '/subscriptions',
      model_class: Subscription,
      template_path: 'subscriptions',
    )

    class Subscriptions < SubscriptionResource
      register Generic::ResourceListRoutes
      register Generic::ResourceViewRoutes

      def dataset
        Subscription.order('id DESC')
      end
    end
  end

  Main.use Routes::Subscriptions
end
