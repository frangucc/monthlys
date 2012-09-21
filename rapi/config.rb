require_relative '../config/global/init.rb'

Recurly.api_key = Monthly::Config::RECURLY_API_KEY
Recurly.js.private_key = Monthly::Config::RECURLY_JS_PRIVATE_KEY
