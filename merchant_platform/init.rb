CONSUMER_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
def consumer_path(*args); File.join(CONSUMER_ROOT, *args); end
MP_ROOT = File.join(CONSUMER_ROOT, 'merchant_platform')
def mp_path(*args); File.join(MP_ROOT, *args); end

require 'rubygems'
require 'bundler'

ENV['BUNDLE_GEMFILE'] = mp_path('Gemfile')
Bundler.setup

require mp_path('/mp/main')
