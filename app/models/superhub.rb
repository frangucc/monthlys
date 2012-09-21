class Superhub
  SUPERHUBS = {
    beverages: { verbose_name: 'Beverages' },
    farmers_market: { verbose_name: 'Farmers market' },
    gifts: { verbose_name: 'Gifts' },
    home_accents: { verbose_name: 'Home accents' },
    local_services: { verbose_name: 'Local Services' },
    pets: { verbose_name: 'Pets' },
    snacks: { verbose_name: 'Snacks' },
  }

  attr_reader(:key, :verbose_name)

  def initialize(key)
    data = SUPERHUBS.fetch(key.to_sym)
    @key = key.to_sym
    @verbose_name = data[:verbose_name]
  end

  def self.find_all_key_name_hash
    Hash[ SUPERHUBS.map{ |k,v| [ v[:verbose_name], k ] } ]
  end

  def self.valid_key?(key)
    SUPERHUBS.keys.include?(key.to_sym)
  end
end
