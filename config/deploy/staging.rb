set :host, "s1.monthlys.com"
role :app, "s1.monthlys.com"
role :web, "s1.monthlys.com"
role :db, "s1.monthlys.com", :primary => true

set :environment, "staging"
set :rails_env, "staging"
set :branch, "staging"

ssh_options[:keys] = [ File.join( ENV['HOME'], '.ssh', 'id_rsa') ]

namespace :db do
  production_db_dump_file = "/home/deploy/dumps/p1-#{Date.today}.dump.gz"
  staging_db_dump_file = "/home/deploy/dumps/s1-#{Date.today}.dump.gz"

  task :production_dump, roles: :db do
    run "ssh deploy@monthlys.com 'pg_dump --no-acl --no-owner --format=tar monthly_production | gzip -c > #{production_db_dump_file}'"
    puts "All done. You can fetch your new PRODUCTION dump with:"
    puts "    scp deploy@monthlys.com:#{production_db_dump_file} ."
  end

  task :backup, roles: :db do
    run "pg_dump --no-acl --no-owner --format=tar monthly_production | gzip -c > #{staging_db_dump_file}"
    puts "All done. You can fetch your STAGING db dump with:"
    puts "    scp deploy@s1.monthlys.com:#{staging_db_dump_file} ."
  end

  desc "Load the production database"
  task :load_production, roles: :db do
    db.production_dump
    run "bash -c '$HOME/bin/load_db deploy@monthlys.com:#{production_db_dump_file}'"
  end

  desc "Load the production database AND sync entities with recurly"
  task :load_production_and_sync, roles: :db do
    db.load_production
    rapi.sync
  end
end

namespace :rapi do
  range = lambda { ENV.fetch("ID_RANGE", nil).tap { |r| r && "[#{r}]" } }

  task :sync do
    sync_accounts
    sync_plans
    sync_coupons
  end

  task :sync_accounts, roles: :db do
    run "cd #{current_path} && yes | bundle exec rake rapi:clear:accounts#{range.call} rapi:sync:monthlys_accounts#{range.call}"
  end

  task :sync_plans, roles: :db do
    run "cd #{current_path} && yes | bundle exec rake rapi:clear:plans#{range.call} rapi:sync:plans#{range.call}"
  end

  task :sync_coupons, roles: :db do
    run "cd #{current_path} && yes | bundle exec rake rapi:clear:coupons#{range.call} rapi:sync:coupons#{range.call}"
  end
end
