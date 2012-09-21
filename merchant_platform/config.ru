require "#{File.dirname(__FILE__)}/init.rb"

map '/mp' do
  use Rack::Session::Cookie, key: '_monthly_session', secret: 'bf221630745b8a1b2ac77adb554f731a30aded67c7331996450db0ac21cbb623be98f4bdaec523a2caa9b14466a293b795cfd126577b07a88493fe373d3d8464'

  use Warden::Manager do |manager|
    manager.failure_app = MP::Main
    manager.default_scope = :user
  end

  Warden::Manager.before_failure do |env, opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  # Devise serialization compat for MP standalone
  class Warden::SessionSerializer
    def serialize(record)
      salt = record.encrypted_password[0,29] if record.encrypted_password
      [record.class.name, record.to_key, salt]
    end

    def deserialize(keys)
      class_name, ids, salt = keys
      record = Kernel.const_get(class_name).find(ids[0])
      record if record && record.encrypted_password[0,29] == salt
    end
  end

  run MP::Main
end
