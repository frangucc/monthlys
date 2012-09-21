set :host, "monthlys.com"
role :app, "monthlys.com"
role :web, "monthlys.com"
role :db, "monthlys.com", :primary => true

set :environment, "production"
set :rails_env, "production"
set :branch, "production"

ssh_options[:keys] = [ File.join( ENV['HOME'], '.ssh', 'id_rsa') ]
