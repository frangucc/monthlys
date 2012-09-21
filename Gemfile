source 'http://rubygems.org'

gem 'rails', '3.1.2'

gem 'pg'
gem 'unicorn'
gem 'activeadmin'
gem 'meta_search', '>= 1.1.0.pre'
gem 'sass-rails', '3.1.5'
gem 'bourbon', '~> 1.2.0'
gem 'aws-s3', require: 'aws/s3'
gem 'redcarpet', '~> 1.17.2'
gem 'recurly', '~> 2.1.5'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'cancan', '1.6.7'
gem 'dalli'
gem 'bitmask_attributes', git: 'git://github.com/sborrazas/bitmask_attributes.git'
gem 'redis'
gem 'lazy_high_charts'
gem 'devise', '~> 2.1.2'
gem 'resque', git: 'git://github.com/defunkt/resque.git', require: 'resque/server'
gem 'resque-scheduler'
gem 'daemon-spawn'
gem 'mini_magick'
gem 'fog'
gem 'carrierwave', '~> 0.5.8'
gem 'airbrake'
gem 'rb-readline'
gem 'formtastic', '2.1.1'
gem 'thinking-sphinx'
gem 'rack-maintenance'

# javascript runtime
gem 'execjs'
gem 'therubyracer'

# Geocoding
gem 'geocoder', '~> 1.1.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'haml'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development, :test do
  gem 'ruby-debug19'
  gem 'capistrano_colors'
end

group :test do
  gem 'minitest',         '~> 3.0'
  gem 'minitest-rails',   '~> 0.1.0.alpha'
  gem 'minitest-capybara'
  gem 'minitest-metadata'
  gem 'poltergeist'

  gem 'database_cleaner', '~> 0.7.1'
  gem 'guard-minitest'
end

group :development do
  gem 'foreman'
  gem 'thin'
  gem 'capistrano', require: false
  gem 'capistrano-ext', require: false
  gem 'capistrano-helpers', require: false
  gem 'capistrano_colors', require: false
  gem 'pry'
end

# MP only gems
group :merchant_platform do
  gem 'bureaucrat'
  gem 'queue_classic', '2.0.0rc4'
end
