class Zipcode < ActiveRecord::Base

  belongs_to :city
  has_and_belongs_to_many :merchants
  has_many :shipping_infos

  before_validation :load_city

  validates :number,
    uniqueness: true,
    format: { with: /^\d{5}(-\d{4})?$/, message: "should be in the form 12345 or 12345-1234" }
  validate :must_have_city

  delegate :state, to: :city, allow_nil: true

  class << self
    def find_or_create_by_number(zipcode_number)
      self.find_by_number(zipcode_number) || self.create(number: zipcode_number)
    end
  end

  def to_s
    self.number
  end

  def country
    'United States'
  end

  def load_city
    if number_changed? || new_record? || !self.city
      self.city = nil # Erasing w/e he has on city to find it again
                      # This way the validation 'must_have_city' will fail if no city was found
      geolocation = Geocoder.search({ postal_code: number, country: 'US' }).first
      if geolocation
        types = ["administrative_area_level_2", "administrative_area_level_3"] # adress component possible types
        possible_city_names = [ geolocation.city ]
        possible_city_names += geolocation.data["address_components"].select {|c| (c["types"] & types).any? }.map {|c| c["long_name"] }

        possible_city_names.each do |city_name|
          break if (self.city = City.find_by_google_name_and_state_code(city_name, geolocation.state_code))
        end

        # If it wasnt found in our DB then create it
        if !self.city && geolocation.city && (state = State.find_by_code(geolocation.state_code))
          self.city = City.create(name: geolocation.city, state: state, google_name: geolocation.city)
        end
      end
    end
    true
  end

  def must_have_city
    errors.add(:base, 'Number is not supported') if !self.city && errors.empty? # Only show this error if it's the only error
  end
end
