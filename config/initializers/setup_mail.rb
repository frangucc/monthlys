ActionMailer::Base.smtp_settings = {
  address: Monthly::Config::MAIL_HOST,
  port: Monthly::Config::MAIL_PORT,
  domain: Monthly::Config::MAIL_DOMAIN,
  user_name: Monthly::Config::MAIL_USERNAME,
  password: Monthly::Config::MAIL_PASSWORD,
  authentication: 'plain',
  enable_starttls_auto: true
}
# ActionMailer::Base.default_url_options[:host] = ENV['HOST']

Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
