module Monthly
  module Config
    # Important, DO NOT use ||= on constants that can have false as value, use
    # something like:
    # DEBUG = false unless defined?(DEBUG) && DEBUG

    # Recurly settings
    RECURLY_SUBDOMAIN ||= ENV['RECURLY_SUBDOMAIN']
    RECURLY_API_KEY ||= ENV['RECURLY_API_KEY']
    RECURLY_JS_PRIVATE_KEY ||= ENV['RECURLY_JS_PRIVATE_KEY']
    RECURLY_MIN_INVOICE_NUMBER ||= 1000

    # S3
    S3_KEY ||= ENV['S3_KEY']
    S3_SECRET ||= ENV['S3_SECRET']
    S3_BUCKET ||= ENV['S3_BUCKET']

    # Mail
    MAIL_USERNAME ||= ENV['GMAIL_USERNAME']
    MAIL_PASSWORD ||= ENV['GMAIL_PASSWORD']
    MAIL_DOMAIN ||= ENV['DOMAIN']
    # Hardcoded defaults for backwards compat, move to env when servers ENV gets updated
    MAIL_HOST ||= 'smtp.gmail.com'
    MAIL_PORT ||= 587

    # Facebook
    APP_ID ||= ENV['APP_ID']
    APP_SECRET ||= ENV['APP_SECRET']

    # Auth
    WARDEN_PASSWORD_PEPPER ||= nil
    WARDEN_PASSWORD_STRETCHES ||= 10

    # debug
    JS_DEBUG = false unless defined?(JS_DEBUG) && JS_DEBUG
    JS_DEBUG_REQUIREJS = false unless defined?(JS_DEBUG_REQUIREJS) && JS_DEBUG_REQUIREJS

    # Assets digests
    ASSETS_DIGESTS = ENV['ASSETS_DIGESTS'] unless defined?(ASSETS_DIGESTS) && ASSETS_DIGESTS
  end
end
