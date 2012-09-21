require File.expand_path('global/init', File.dirname(__FILE__))

# Load the rails application
require consumer_path('config/application')

# Initialize the rails application
Monthly::Application.initialize!
