require mp_path('mp/forms/base')

module MP
  module Forms
    class PlanShipping < Form
      SHIPPING_OPTIONS = [
        [:free, 'Free Shipping'],
        [:flat, 'Flat Rate'],
        [:by_state, 'Fixed Rate by State']
      ]

      radio_choice :shipping, SHIPPING_OPTIONS
      integer :rate  # required only if flat-rate
    end

    class BusinessInformation < Form
      string :business_name, label: 'Business Name'
      string :contact_name, label: 'First Name'
      string :contact_last_name, label: 'Last Name'
      email :email
      string :website
      text :about, label: 'Tell us a bit about your business'
      string :phone, label: 'Phone Number'
      string :address1, label: 'Address I'
      string :address2, label: 'Address II', required: false
      string :city
      string :state, label: 'State / Province'
      integer :zipcode, label: 'Zip Code'
      string :country
    end


    class StoreFront < Form
      file :logo, label: 'Logo',
           widget: Bureaucrat::Widgets::ImageInput,
           help_text: 'Maximum size 700kb. JPG, GIF, PNG.'
      file :image, label: 'Image',
           widget: Bureaucrat::Widgets::ImageInput,
           help_text: 'Maximum size 700kb. JPG, GIF, PNG.'
      string :video_url, label: 'Video URL',
             help_text: 'Youtube and Vimeo links supported. Include http://'
      string :video_thumbnail_url, label: 'Video Thumbnail',
             help_text: 'Maximum size 700kb. JPG, GIF, PNG.'
    end


    class Marketing < Form
      boolean :marketplace, label: 'Marketplace',
              help_text: 'The Monthlys marketplace gives you access to
                          thousands of local customers and gives your business
                          tons of exposure. We do not recommend disabling this
                          feature.',
              required: false
      boolean :custom_site, label: 'Custom Site',
              help_text: 'Design and configure your own custom subscription
                          site. Use this platform for your private marketing
                          channels.',
              required: false
      boolean :point_of_sale, label: 'Point of Sale',
              help_text: 'Monthlys will deliver to your location, point of sale
                          stationary and collateral for your customers.
                          Monthlys is quickly becoming a recognizable local
                          service, so having Point of Sale enabled is highy
                          recommended.  There is no chage for point of sale
                          stationary or design.',
              required: false
    end

    class ServiceArea < Form
      DELIVERY_TYPES = [
        [:zipcodes,   'Zip Code'],
        [:cities,     'Cities'],
        [:states,     'States'],
        [:nationwide, 'Nation Wide']
      ]

      DELIVERY_TYPES_MAP = {
        zipcodes:   Merchant::DELIVERY_TYPE::ZIPCODE_LIST,
        cities:     Merchant::DELIVERY_TYPE::CITY_LIST,
        states:     Merchant::DELIVERY_TYPE::STATE_LIST,
        nationwide: Merchant::DELIVERY_TYPE::NATIONWIDE
      }

      DELIVERY_TYPES_REVERSE_MAP = {
        Merchant::DELIVERY_TYPE::ZIPCODE_LIST => :zipcodes,
        Merchant::DELIVERY_TYPE::CITY_LIST    => :cities,
        Merchant::DELIVERY_TYPE::STATE_LIST   => :states,
        Merchant::DELIVERY_TYPE::NATIONWIDE   => :nationwide
      }

      radio_choice :delivery_type, DELIVERY_TYPES
      field :zipcodes, Bureaucrat::Fields::ModelInstanceMultiselect.new(
                          Zipcode, required: false)
      field :cities, Bureaucrat::Fields::ModelInstanceMultiselect.new(
                          City, required: false)
      field :states, Bureaucrat::Fields::ModelInstanceMultiselect.new(
                          State, required: false)

      def self.initial_for(record)
        super(record).merge({
          delivery_type: DELIVERY_TYPES_REVERSE_MAP[record.delivery_type]
        })
      end

      def clean_delivery_type
        @cleaned_data['delivery_type_raw'] = @cleaned_data['delivery_type']
        DELIVERY_TYPES_MAP[@cleaned_data['delivery_type'].to_sym]
      end

      def clean_values(name)
        if @cleaned_data['delivery_type_raw'] == name
          raise Bureaucrat::ValidationError.new("Select one value at least") \
                  if @cleaned_data[name].empty?
          @cleaned_data[name]
        else
          []
        end
      end

      def clean_zipcodes; clean_values('zipcodes'); end
      def clean_cities; clean_values('cities'); end
      def clean_states; clean_values('states'); end
    end
  end
end
