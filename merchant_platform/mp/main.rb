require 'logger'

# Loads settings
require consumer_path('config/global/init')
require mp_path('mp/config/init')
# Loads and setup consumer site models
require mp_path('mp/models')
# Loads auth system
require mp_path('mp/auth')
# Loads template engine
require mp_path('mp/templates')
# Fix Bureaucrat for now
require mp_path('lib/bureaucrat_fixes/temporary_uploaded_file')
require mp_path('lib/bureaucrat_fixes/widgets')
# Configure CarrierWave
require consumer_path('config/initializers/carrierwave')

# Sinatra app and routes
require 'sinatra'
module MP
  class Main < Sinatra::Base
    use Rack::Static, urls: %w{/css /img /js /ui}, root: mp_path()

    TPL = MP::Templates::TemplateMgr.new(MP::Conf::TEMPLATE_PATH)

    configure do
      set :method_override, true
      set :logging, MP::Conf::SINATRA_LOGGING
    end

    configure :development do
      require 'rack/reloader'
      Sinatra::Application.reset!
      use Rack::Reloader
    end
  end
end
require mp_path('mp/routes')
require mp_path('mp/jobs')
