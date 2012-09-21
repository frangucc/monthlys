require File.expand_path('../boot', __FILE__)
require 'rack/maintenance'
require 'rails/all'
require 'middleware/redirect_to_back_for_omniauth'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Monthly
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/admin)
    config.autoload_paths += Dir["#{config.root}/lib/monthly/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/monthly/**/*.rb"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Config needed for ActiveAdmin
    config.assets.initialize_on_precompile = false

    # Show proper markup for the fields with errors
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| "#{html_tag}".html_safe }

    # Config for the app internal environment depending variables
    # This will create a new set of configuration variables
    # For more info: http://jasonnoble.org/2011/12/updated-rails3-custom-environment-variables.html
    app_config = ActiveSupport::OrderedOptions.new

    app_config.email_validation_regex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i

    # Default coupon codes for the two coupons
    REGISTERING_5_COUPON_CODE = '281LA21TQ2'
    REGISTERING_10_COUPON_CODE = 'H91OAL014J'
    INVITING_COUPON_CODE = 'UA94721MP0'

    app_config.register_coupons = {
      register_5_dollar_coupon: {
        coupon_code: REGISTERING_5_COUPON_CODE,
        et_mail_name: 'coupon_signed_up'
      },
      register_10_dollar_coupon: {
        coupon_code: REGISTERING_10_COUPON_CODE,
        et_mail_name: 'coupon_signed_up_10' # TODO: Fede please verify
      }
    }

    app_config.localized_superhubs_list = %w(local_services).map(&:to_sym)

    config.app_config = app_config

    # Maximum number of plans available for a user to display the compact plans listing
    TOO_FEW_PLANS = 20

    config.generators do |g|
      g.test_framework :mini_test, :spec => true, :fixture => true
      g.integration_tool :mini_test
    end

    config.exact_target_enabled = false

    config.middleware.use RedirectToBackForOmniauth

    config.middleware.use 'Rack::Maintenance', file: Rails.root.join('public', 'maintenance.html'), env: 'MAINTENANCE'
  end
end
