begin
  require ENV['MP_SETTINGS'] || mp_path('mp/config/settings.rb')
rescue LoadError
  warn 'WARNING: "mp/config/settings.rb" not found and no MP_SETTINGS ' +
       'env var given, using only default settings'
end
require mp_path('mp/config/default_settings.rb')
