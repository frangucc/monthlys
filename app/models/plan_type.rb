class PlanType

  TYPES = {
    consumables: { name: 'Food or Beverage',  shippable: true },
    services:    { name: 'At Home Service',   shippable: true },
    memberships: { name: 'Memberships',       shippable: false },
    products:    { name: 'Tangible Products', shippable: true },
    online:      { name: 'Online Service',    shippable: false }
  }.freeze

  SUBTYPES = {
    # Consumables
    durable:          { type: :consumables, name: 'Durable Goods' },
    perishable:       { type: :consumables, name: 'Perishable Goods' },
    local_delivery:   { type: :consumables, name: 'Local Delivery' },
    alcohol:          { type: :consumables, name: 'Alcoholic Beverage' },
    warm_food:        { type: :consumables, name: 'Warm Food' },
    other_consumable: { type: :consumables, name: 'Other' },
    # Services
    landscaping:   { type: :services, name: 'Landscaping' },
    cleaning:      { type: :services, name: 'Cleaning' },
    theraputic:    { type: :services, name: 'Massage or Therapy Service' },
    caretaking:    { type: :services, name: 'Caretaking Service' },
    pet_service:   { type: :services, name: 'Pet Service' },
    training:      { type: :services, name: 'Training' },
    education:     { type: :services, name: 'Educational' },
    other_service: { type: :services, name: 'Other' },
    # Memberships
    tanning:          { type: :memberships, name: 'Cafe' },
    club:             { type: :memberships, name: 'Club' },
    training_center:  { type: :memberships, name: 'Training Center' },
    educational:      { type: :memberships, name: 'Education Center' },
    pet_center:       { type: :memberships, name: 'Pet Center' },
    gym:              { type: :memberships, name: 'Gym' },
    tutoring:         { type: :memberships, name: 'Tutoring' },
    other_membership: { type: :memberships, name: 'Other' },
    # Products
    accessories:   { type: :products, name: 'Accessories' },
    clothing:      { type: :products, name: 'Clothing' },
    shoe:          { type: :products, name: 'Shoe' },
    personal_care: { type: :products, name: 'Personal Care' },
    beauty:        { type: :products, name: 'Beauty' },
    other_product: { type: :products, name: 'Other' },
    # Online
    content:         { type: :online, name: 'Content' },
    entertainment:   { type: :online, name: 'Video & Music' },
    online_training: { type: :online, name: 'Training' },
    news:            { type: :online, name: 'News' },
    other_online:    { type: :online, name: 'Other' },
  }.freeze

  def self.get_all_types
    TYPES
  end

  def self.get_all_subtypes
    SUBTYPES
  end

  # Subtypes keys arrays gruped by type keys
  #
  # Ex:
  #
  #  {:consumables=>
  #    [[:durable, "Durable Goods"],
  #     ...
  #     [:other_consumable, "Other"]],
  #   :services=>
  #    [[:landscaping, "Landscaping"],
  #    ...
  #  }
  #
  # Returns an array with type key as key and an array of arrays
  # subtype key / name as value.
  def self.subtypes_by_types
    Hash.new{ |h,k| h[k] = [] }.tap do |h|
      SUBTYPES.each { |type_key, v| h[v[:type]] << [type_key, v[:name]] }
    end
  end

  def self.get_subtype_str(subtype)
    tname = self.get_type(subtype)[:name]
    stname = SUBTYPES[subtype.to_sym][:name]
    "#{tname} - #{stname}"
  end

  def self.get_type_key(subtype)
    SUBTYPES[subtype.to_sym][:type]
  end

  def self.get_type(subtype)
    TYPES[self.get_type_key(subtype)]
  end

  # Checks if the given type is the type associated with the given subtype.
  # Returns a boolean.
  def self.valid_subtype?(type, subtype)
    subtype && type.to_sym == get_type_key(subtype)
  end
end
