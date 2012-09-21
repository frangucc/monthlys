# Consumer Site
require ::File.expand_path('../config/environment',  __FILE__)
map '/' do
  run Monthly::Application
end

# Rapi/Recurly push notifications
require ::File.expand_path('../rapi/push/main',  __FILE__)
map '/rapi' do
  run Monthly::Rapi::Push::Main
end

# Merchant Platform
require ::File.expand_path('../merchant_platform/init', __FILE__)
map '/mp' do
  use Rack::Session::Cookie, key: '_monthly_session', secret: 'bf221630745b8a1b2ac77adb554f731a30aded67c7331996450db0ac21cbb623be98f4bdaec523a2caa9b14466a293b795cfd126577b07a88493fe373d3d8464'

  use Warden::Manager do |manager|
    manager.failure_app = MP::Main
    manager.default_scope = :user
  end

  Warden::Manager.before_failure do |env, opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  run MP::Main
end
