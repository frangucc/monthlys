require mp_path('lib/sinatra_url/url')
require mp_path('mp/sinatra/ext')
require mp_path('mp/sinatra/helpers')

module MP
  module Routes
    class RoutesBase < Sinatra::Base
      register Sinatra::URL
      register MP::SinatraExt::AppContext
      register MP::SinatraExt::RouteNotFound
      helpers MP::SinatraHelpers::AppContext
      helpers MP::SinatraHelpers::Auth
      helpers MP::SinatraHelpers::Debug
      helpers MP::SinatraHelpers::Templates
      helpers MP::SinatraHelpers::Ajax
      helpers MP::SinatraHelpers::Pagination
    end

    # Explicitly require all route files here
    require mp_path('mp/routes/generic/db_resources')
    require mp_path('mp/routes/main')
    require mp_path('mp/routes/auth')
    require mp_path('mp/routes/merchants')
    require mp_path('mp/routes/storefronts')
    require mp_path('mp/routes/marketing')
    require mp_path('mp/routes/plans')
    require mp_path('mp/routes/subscriptions')
    require mp_path('mp/routes/servicearea')
    require mp_path('mp/routes/admin_users')
    require mp_path('mp/routes/wizard')
    require mp_path('mp/routes/cities')
    require mp_path('mp/routes/categories')
    require mp_path('mp/routes/coupons')
  end
end
