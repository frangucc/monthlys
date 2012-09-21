# Explicitly require all model files and related deps here

# External deps
require 'active_record'
require 'bitmask_attributes'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'geocoder'
require 'geocoder/railtie'
require 'active_support/core_ext/numeric/bytes.rb'
require 'active_support/core_ext/module.rb'
require 'action_view/helpers/number_helper.rb'
require consumer_path('config/initializers/geocoder')
require consumer_path('app/uploaders/image_uploader')
require consumer_path('app/uploaders/merchant_logo_uploader')
require consumer_path('app/uploaders/file_uploader')
require consumer_path('lib/monthly/exact_target/emailable')

Geocoder::Railtie.insert

ActiveRecord::Base.establish_connection(MP::Conf::DATABASE_HASH)

# Patches

# Make devise call dummy
class User < ActiveRecord::Base
  def self.devise(*args)
  end
end

require consumer_path('app/models/user')
require consumer_path('app/models/merchant')
require consumer_path('app/models/category')
require consumer_path('app/models/plan_recurrence')
require consumer_path('app/models/option')
require consumer_path('app/models/option_group')
require consumer_path('app/models/subscription')
require consumer_path('app/models/plan')
require consumer_path('app/models/recurrence')
require consumer_path('app/models/plan_type')
require consumer_path('app/models/plan_document')
require consumer_path('app/models/attachment')
require consumer_path('app/models/zipcode')
require consumer_path('app/models/city')
require consumer_path('app/models/state')
require consumer_path('app/models/coupon')
require consumer_path('app/models/shipping_info')
require consumer_path('app/models/invoice')
require consumer_path('app/models/transaction')
require consumer_path('app/models/subscription_option')
