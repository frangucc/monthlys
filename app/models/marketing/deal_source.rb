class Marketing::DealSource < ActiveRecord::Base

  mount_uploader :image, ImageUploader do
    process :resize_to_fit => [nil, 30]
  end

  validates :url_code, presence: true, format: { with: /^[a-z\d]+$/, message: 'must have lowercase letters, numbers and underscores only' }
  validates :name, presence: true

  class << self
    def find_by_url_code(url_code) # Case-insensitive
      return unless url_code
      self.where('marketing_deal_sources.url_code ILIKE ?', url_code).first
    end
  end
end
