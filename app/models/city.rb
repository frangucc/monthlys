class City < ActiveRecord::Base

  belongs_to :state
  has_and_belongs_to_many :merchants
  has_many :users
  has_many :zipcodes

  mount_uploader :image, ImageUploader do
    process resize_to_fit: [1440, nil]
  end

  validates :name, :presence => true
  validates :state, :presence => true
  
  default_scope order('cities.name ASC')
  scope :featured, where({ is_featured: true })

  class << self
    def find_by_google_name_and_state_code(name, state_code)
      self.includes(:state).where(['cities.google_name = ? AND states.code = ?', name, state_code]).first
    end
  end

  def to_s
    "#{name}, #{state}"
  end
end
