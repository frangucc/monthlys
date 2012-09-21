class DevelopmentMailInterceptor
  def self.delivering_email(email)
    email.subject = "#{email.to} #{email.subject}"
    if defined?(Monthly::Config::DEVELOPMENT_REDIRECT_EMAIL)
      email.to = Monthly::Config::DEVELOPMENT_REDIRECT_EMAIL
    else
      email.perform_deliveries = false
    end
  end
end
