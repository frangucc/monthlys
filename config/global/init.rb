require 'json'

# Global setup, common to the consumer site and merchant platform.

def consumer_path(*args)
  File.join(File.expand_path('../..',  File.dirname(__FILE__)), *args)
end

def mp_path(*args)
  consumer_path('merchant_platform', *args)
end

# Load global config settings

begin
  require ENV['MONTHLY_SETTINGS'] || consumer_path('config/global/settings.rb')
rescue LoadError
  warn('WARNING: "config/global/settings.rb" not found and no ' +
       'MONTHLY_SETTINGS env var given, using only default settings')
end
require consumer_path('config/global/default_settings.rb')

# Read js digests db to mem
if Monthly::Config::ASSETS_DIGESTS
  alternatives = JSON.parse(File.open("#{consumer_path}/config/jsdigests.json", 'r').read())
  Monthly::Config::ASSETS_DIGESTS_ALTERNATIVES = alternatives
end

# Load global libs

require consumer_path('rapi/rapi')
