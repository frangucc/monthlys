# Current tasks flow (keep it up to date):
#
#  + deploy                                #
#  |  ^                                    #
#  |  |                                    #
#  |  ~                                    #
#  + deploy:update                         # * Starts the transaction
#  |  ~                                    #
#  |  |    +-- thinking_sphinx:stop        # * Stop search server.
#  |  |    |                               #
#  |  ~    v                               #
#  + deploy:update_code                    # * Update code to latest commit in
#  |  ~  ^                                 #   git branch and cp to release dir.
#  |  |  |   +-- deploy:assets:symlink     # * ln REL_DIR/public/assets
#  |  |  |   |                             #   to shered/assets.
#  |  ~  ~   v                             #
#  + deploy:finalize_update                # * Change release dir perms and ln
#  |  ~  ~   ^                             #   public/system/, log/ and tmp/pids.
#  |  |  |   |                             #
#  |  |  |   +-- bundle:install            # * Install new gems with bundle
#  |  |  |                                 #
#  |  |  +-- deploy:assets:precompile      # * Precompile assets
#  |  |         ^                          #
#  |  |         |                          #
#  |  |         +-- js:compile             # * Compile js files.
#  |  |                                    #
#  |  |  +-- deploy:symlink_privates       # * ln privates (database.yml)
#  |  |  +-- deploy:symlink_shared         # * ln shared/assets and
#  |  |  |                                 #   shared/public/system to release dir.
#  |  |  |     +-- thinking_sphinx:index   # * Reindex search server.
#  |  |  |     |                           #
#  |  |  |     v                           #
#  |  |  +-- thinking_sphinx:start         # * Start search server.
#  |  ~                                    #
#  + deploy:create_symlink                 # * Point current code to new release
#  + deploy:restart                        # * Restart web server
#     ~                                    #
#     |                                    #
#     + deploy:migrate                     # * Run db migrations.
#     |  ^                                 #
#     |  |                                 #
#     |  +-- resque:restart                # * Restart resque server.
#     |                                    #
#     |  +-- airbreak:deploy               # * Notify airbreak of deploy.
#     |  |                                 #
#     |  v                                 #
#     + deploy:cleanup                     # * Delete old releases, keeping latest five.
#                                          #
require 'bundler/capistrano'
require 'capistrano-helpers/privates'
require 'capistrano-helpers/shared'
require './config/boot'
require 'thinking_sphinx/deploy/capistrano'
begin
  require 'capistrano_colors'
rescue LoadError
end



########### Settings ############


depend :local, :command, 'git'

set :application, 'monthlys'
set :repository, 'git@github.com:frangucc/monthly.git'
set :branch, 'master'
set :project_root, File.join(File.dirname(__FILE__),'..')

set :user, :deploy
set :use_sudo, false

set :stages, [:production, :staging]
set :default_stage, :staging
# This must be required after configuring the stages
require 'capistrano/ext/multistage'

set :scm, :git
set :git_enable_submodules, false

set :deploy_to, "/var/www/rails_apps/#{ application }"
set :deploy_via, :remote_cache
set :bundle_without, [:development, :test, :darwin]

set :shared, %w{
  public/system
  assets
}

set :privates, %w{
  config/database.yml
}

default_run_options[:pty] = true



########### Custom tasks ############


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :resque do
  desc 'Start Resque workers'
  task :start, roles: :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bin/resque-worker start"
    #run "cd #{current_path} && bin/resque-scheduler start"
  end

  desc 'Stop Resque workers'
  task :stop, roles: :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bin/resque-worker stop"
    #run "cd #{current_path} && bin/resque-scheduler stop"
  end

  desc 'Check status of Resque workers'
  task :status, roles: :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bin/resque-worker status"
    #run "cd #{current_path} && bin/resque-scheduler status"
  end

  desc 'Restart Resque workers'
  task :restart, roles: :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bin/resque-worker restart"
    #run "cd #{current_path} && bin/resque-scheduler stop && bin/resque-scheduler start"
  end
end

namespace :sphinx do
  desc 'Symlink Sphinx indexes'
  task :symlink_indexes, roles: :app do
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end
end

# Based on airbreak's /lib/airbrake/capistrano.rb
namespace :airbrake do
  desc <<-DESC
            Notify Airbrake of the deployment by running the notification on the REMOTE machine.
              - Run remotely so we use remote API keys, environment, etc.
          DESC
  task :deploy, except: { no_release: true } do
    rails_env = fetch(:rails_env, 'production')
    airbrake_env = fetch(:airbrake_env, fetch(:rails_env, 'production'))
    local_user = ENV['USER'] || ENV['USERNAME']
    executable = fetch(:rake, 'rake')
    directory = current_release
    notify_command = "cd #{directory}; #{executable} RAILS_ENV=#{rails_env} airbrake:deploy TO=#{airbrake_env} REVISION=#{current_revision} REPO=#{repository} USER=#{local_user}"
    notify_command << " DRY_RUN=true" if dry_run
    notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
    logger.info "Notifying Airbrake of Deploy (#{notify_command})"
    if dry_run
      logger.info "DRY RUN: Notification not actually run."
    else
      result = ''
      run(notify_command, once: true) { |ch, stream, data| result << data }
    end
    logger.info 'Airbrake Notification Complete.'
  end
end

namespace :js do
  desc 'Compile JS files'
  task :compile do
    run "cd #{release_path} && ./script/buildjs -d && ./script/buildadminjs"
  end
end

########### Hooks ############


# Symlink privates (database.yml)
#before "deploy:assets:precompile", "deploy:symlink_privates"

# Db migration
after 'deploy', 'deploy:migrate'

# JS assets compile
after 'deploy:assets:precompile', 'js:compile'

# Cleanup old releases
after 'deploy', 'deploy:cleanup'

# Resque
after 'deploy:migrate', 'resque:restart'

# Sphinx search
before 'deploy:update_code', 'thinking_sphinx:stop'
after 'deploy:update_code', 'thinking_sphinx:start'
before 'thinking_sphinx:start', 'thinking_sphinx:index'

# Airbreak notification
before 'deploy:cleanup', 'airbrake:deploy'
