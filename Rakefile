#!/usr/bin/env rake
require File.expand_path('../config/application', __FILE__)

# Load railtie and lib/tasks/* tasks
Monthly::Application.load_tasks
# Load Rapi tasks from Rapi module
require_relative 'rapi/tasks.rb'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = Dir.glob("spec/**/*_spec.rb")
  t.verbose = true
end