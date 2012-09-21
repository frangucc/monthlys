module MP
  module Conf

    # Important, DO NOT use ||= on constants that can have false as value, Ex. see DEBUG

    DEBUG = false unless defined?(DEBUG) && DEBUG

    SINATRA_LOGGING = false unless defined?(SINATRA_LOGGING) && SINATRA_LOGGING

    DATABASE_HASH ||= begin
      env = ENV['RACK_ENV'] || 'development'
      YAML::load(File.open(consumer_path('config/database.yml')))[env]
    end

    QC_DATABASE_URL ||= begin
      c = DATABASE_HASH
      cred = "#{c['username']}:#{c['password']}@" if c['username'] || c['password']
      adapter = c['adapter'] == 'postgresql' ? 'postgres' : c['adapter']
      "#{adapter}://#{cred}#{c.fetch('host', 'localhost')}/#{c['database']}"
    end
    QC_LOG_LEVEL ||= ENV['QC_LOG_LEVEL'] || Logger::WARN

    LOGOUT_REDIRECT_URL ||= '/mp/'
    LOGIN_URL ||= '/mp/login/'
    LOGIN_REDIRECT_DEFAULT_URL ||= '/mp/'

    TEMPLATE_PATH ||= mp_path('templates/')

    DEVELOPMENT = ENV['RACK_ENV'] == 'development'
  end
end
