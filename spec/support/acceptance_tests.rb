require 'minitest/rails/action_dispatch'
require 'capybara/poltergeist'
require 'capybara/rails'

Capybara.javascript_driver = :poltergeist

class MiniTest::Rails::ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::RSpecMatchers

  before do
    if metadata[:js]
      Capybara.current_driver = Capybara.javascript_driver
    else
      Capybara.current_driver = Capybara.default_driver
    end
  end
end
