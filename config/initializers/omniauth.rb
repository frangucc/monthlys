Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :facebook, Monthly::Config::APP_ID, Monthly::Config::APP_SECRET,
  scope: 'email,offline_access,user_location'
end
