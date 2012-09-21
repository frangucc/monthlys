require "spec_helper"

class Homepage < MiniTest::Rails::ActionDispatch::IntegrationTest
  it "asks for a zipcode", js: true do
    skip "We need to populate the database for this to work"

    visit "/"

    within "#colorbox" do
      page.must_have_content "Please enter your zipcode"
      fill_in "Your Zipcode", with: 60654
      click_button "Submit"
    end

    within ".current-city" do
      page.must_have_content "60654"
    end
  end
end
