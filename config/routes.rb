require 'merchant_storefront_constraint'

Monthly::Application.routes.draw do

  # Authentication callbacks
  match "auth/:provider/callback" => 'authentications#create'
  match "auth/failure" => 'authentications#failure'

  # Resources
  resources :category_groups, only: [:show]
  resources :categories, only: [:index, :show] do
    collection do
      get :highlights
    end
  end
  resources :tags, only: [:show] do
    member do
      get :highlights
    end
  end
  resources :merchants, only: [:new, :create] do
    member do
      get :thank_you
      get :terms
    end
  end
  resources :subscriptions do
    member do
      get :confirm_destroy
      post :reactivate
      get :confirm_reactivate
      get :thank_you
    end
    collection do
      get :totals
    end
  end
  resources :user_preferences, only: [:index, :create, :destroy] do
    collection do
      get :my_preferences
    end
  end
  resources :authentications, only: [:index, :create, :destroy]
  resources :plans, only: [:index, :show] do
    collection do
      get :filtered
    end
    member do
      get :preview
      get :summary
      get :subscription_archive
    end
    resource :configurator, controller: 'plan_configurators', only: [] do
      get :zipcode_confirmation
      post :zipcode_confirmation, action: :zipcode_confirmation_submit
      # Plans#show js routes
      get :display_totals

      # Configurator only stuff
      get :coupon_valid
      get :checkout
      get :confirmation
      post :submit
      post :submit_shipping_info
    end
  end
  resource :settings, controller: 'settings', only: [:edit, :update] do
    collection do
      get :persistent_dismiss
      get :edit_password
      put :update_password
      get :update_location
      post :enter_zip
    end
  end
  resource :billing_info, only: [:new, :show, :edit, :destroy] do
    post :callback
    get :delete
  end
  resources :shipping_infos, except: [:show] do
    member do
      get :edit_confirmation
      get :delete
    end
  end
  resources :coupons, only: [:index] do
    collection do
      get :search
    end
  end
  resources :newsletter_subscribers, only: [:create]
  resources :superhubs, only: [:show]
  resource :search, only: [ :show ]

  # Redeem is Coupons#index
  get 'redeem', to: 'coupons#index', as: :coupons_index

  resources :friends, only: [:new, :create]

  # Active Admin
  begin
    ActiveAdmin.routes(self)
    get '/admin/tags/:id' => 'admin/keyword_tags#show', as: :admin_tag
    get '/admin/transactions/:id' => 'admin/transactions#show', as: :admin_transaction
  rescue ActiveRecord::StatementInvalid, PG::Error
    # See #504 for the problem that prompts this horrible begin/rescue.
    warn "ActiveAdmin tried to access the database, but it's not ready"
  end

  namespace :admin do
    constraints CanAccessResque do
      mount Resque::Server, at: '/resque'
    end
  end

  # Users
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' } do
    get 'sessions/form' => 'sessions#form'
    get 'registrations/form' => 'registrations#form'
    get 'passwords/confirmation' => 'passwords#confirmation'
  end
  as :user do
    post 'user_location' => 'sessions#user_location'
    put 'inactivate' => 'registrations#inactivate', as: :inactivate_user_registrations
    get '/users/sign_out' => 'sessions#destroy'

    # Coupons registration
    get 'users/:coupon_name' => 'registrations#new_with_coupon', as: :coupon_registration
    post 'users/create_with_coupon' => 'registrations#create_with_coupon', as: :create_with_coupon
    match '/register_and_get_a_coupon' => redirect('/users/register_5_dollar_coupon')
  end

  # Static pages
  static_routes = %w(
    home
    deals
    featured
    coming_soon
    about
    how-it-works
    terms_of_service
    affiliate_program
    privacy_policy
    why-monthlys
    what-is-monthlys
    jobs
    quality
    guarantee
    contact
    affiliate-program
    sitemap
    record
    beer
  )
  static_routes.each do |action_name|
    get action_name, to: "pages##{action_name.underscore}", as: action_name.underscore
  end

  post 'contact', to: 'pages#contact_submit'

  # Business static pages (merchant marketing site)
  get "business", to: 'business#home'
  get "business/merchants"
  get "business/platform"
  get "business/marketplace"
  get "business/features"
  get "business/reviews"
  get "business/why"
  get "business/custom"
  get "business/categories"
  get "business/developers"

  # Facebook static pages
  get 'facebook/handpicked', to: 'facebook#handpicked'
  get 'facebook/get_10_off', to: 'facebook#get_10_off'

  # Mail web routes
  get 'mail/affiliate_program', to: 'mail#affiliate_program'
  get 'mail/daily_3', to: 'mail#daily_3'
  get 'mail/grand_opening/:id', to: 'mail#grand_opening'
  get 'mail/coupon_invite_5_friends/:id', to: 'mail#coupon_invite_5_friends'
  get 'mail/coupon_invited_5_friends/:id', to: 'mail#coupon_invited_5_friends'
  get 'mail/coupon_sign_up/:id', to: 'mail#coupon_sign_up'
  get 'mail/coupon_signed_up/:id', to: 'mail#coupon_signed_up'
  get 'mail/coupon_signed_up_10/:id', to: 'mail#coupon_signed_up_10'
  get 'mail/new_merchant/:id', to: 'mail#new_merchant'
  get 'mail/new_preference/:id', to: 'mail#new_preference'
  get 'mail/new_user/:id', to: 'mail#new_user'
  get 'mail/new_user_set_preferences/:id', to: 'mail#new_user_set_preferences'
  get 'mail/set_preferences_reminder', to: 'mail#set_preferences_reminder'
  get 'mail/welcome_channel_leads', to: 'mail#welcome_channel_leads'
  get 'mail/popular_national_subscriptions', to: 'mail#popular_national_subscriptions'
  get 'mail/fathers_day', to: 'mail#fathers_day'
  get 'mail/reactivate_email/:id', to: 'mail#reactivate_email', as: 'reactivate_email'

  # Notification web routes
  get 'mail/giftee_email/:id', to: 'notification_mailer#send_giftee_subscription_email'
  get 'mail/shipments/:id', to: 'notification_mailer#send_user_tracking_number_email', as: 'shipment_email'

  # Root
  root to: 'pages#featured'
  #root to: 'plans#filtered', defaults: { filter: { discover: 'handpicked' } }

  # Marketing
  namespace :marketing, module: 'marketing' do
    resources :newsletters, only: [:show]
    resources :user_attachments, only: [:new, :create]
    resources :pages do
      collection do
        get :rewards
      end
    end
  end
  get 'rewards', to: 'marketing/pages#rewards', as: :rewards

  get 'stickit' => 'marketing/user_attachments#new', as: :stickit

  # Merchant storefront
  scope ':custom_site_url', module: 'merchant_storefront', as: 'merchant_storefront', constraints: MerchantStorefrontSiteConstraint.new do
    match '/', to: 'plans#home'

    resources :plans, only: [:index] do
      collection do
        get :home
      end
    end

    get '/how_it_works', to: 'pages#how_it_works'
    get '/contact', to: 'pages#contact'
    get '/about', to: 'pages#about'
    post '/contact', to: 'pages#contact_submit'
  end

  scope ':custom_site_url', constraints: MerchantStorefrontSiteConstraint.new do
    # Resources
    resources :subscriptions, only: [:index, :show, :destroy] do
      member do
        get :confirm_destroy
        post :reactivate
        get :confirm_reactivate
        get :thank_you
      end
      collection do
        get :totals
      end
    end
    resources :coupons, only: [:index] do
      collection do
        get :search
      end
    end
    resources :plans, only: [:index, :show] do
      collection do
        get :filtered
      end
      member do
        get :preview
      end
      resource :configurator, controller: 'plan_configurators', only: [] do
        # Plans#show js routes
        get :display_totals

        # Configurator only stuff
        get :checkout
        get :confirmation
        get :coupon_valid
        post :submit
        post :submit_billing_info
        post :submit_shipping_info
      end
    end
    resource :settings, controller: 'settings', only: [:edit, :update] do
      get :edit_password
      put :update_password
    end
    resource :billing_info, only: [:new, :show, :edit, :destroy] do
      post :callback
      get :delete
    end
    resources :shipping_infos, except: [:show] do
      member do
        get :edit_confirmation
        get :delete
      end
    end

    # Sign out path
    as :user do
      get '/users/sign_out' => 'devise/sessions#destroy'
    end
  end
end
