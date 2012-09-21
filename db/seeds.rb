# Create a default user
unless AdminUser.find_by_email('admin@monthlys.com')
  AdminUser.create(:email => 'admin@monthlys.com', :password => 'wearegonnarock', :password_confirmation => 'wearegonnarock')
end

# Load US Cities
unless City.any?
  
  # Production Configuration
  #cities_path = Rails.root.to_s + '/lib/seeds/cities.yml'
  
  # Localhost Configuration - switch to production after running seed file locally
   cities_path = File.join('lib/seeds', 'cities.yml')
  
  
  YAML::load_file(cities_path).each do |obj|
    obj["name"] = obj["name"].titleize
    City.create!(obj)
  end
end
