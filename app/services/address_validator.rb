class AddressValidator

  attr_accessor :errors, :error_codes

  def initialize(address_attributes, options = {})
    @attributes = address_attributes.symbolize_keys
    @merchant = options.fetch(:merchant, nil)

    @errors = Hash.new { |h,k| h[k] = [] }
    @error_codes = []
  end

  def valid?
    validates_presence_of :first_name, :last_name, :address1, :city, :phone
    validates_zipcode

    @errors.empty?
  end

  def validates_zipcode
    errors = []

    zipcode = Zipcode.find_or_create_by_number(@attributes[:zipcode_str])
    state = State.find_by_id(@attributes[:state_id])

    if zipcode.valid?
      if (zipcode.number != '99999') && (!state || state.id != zipcode.state.id)
        errors << 'Zip Code state doesn\'t match'
      end
    else
      errors.concat(zipcode.errors.full_messages)
    end

    if @merchant && errors.empty? && !@merchant.supports_zipcode?(zipcode)
      errors << 'The merchant does not deliver to this area.'
      error_codes << :out_of_area
    end

    @errors[:zipcode_str] = errors if errors.any?
  end

  def validates_presence_of(*attr_names)
    errmsg = 'This field can\'t be blank'
    attr_names.each do |attr_name|
      @errors[attr_name] << errmsg if @attributes[attr_name].blank?
    end
  end
end
