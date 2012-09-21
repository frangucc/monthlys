ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
require 'minitest/pride'

# Automatically require every file in spec/support. This file should not be
# modified :)
Dir["spec/support/**/*.rb"].each do |helper|
  require "./#{helper}"
end
