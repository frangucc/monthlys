class Marketing::VideoReview < ActiveRecord::Base

  belongs_to :plan

  scope :active, where(is_active: true)

  mount_uploader :thumbnail, ImageUploader do
    process resize_to_fill: [108, 83]
  end

  scope :active, where(is_active: true)
  scope :featured, where(is_featured: true)

  # RAW_URL_REGEX = /videos.getbravo.com\/embed\/([\w\d]+)(?:\/.*secret=(\d+))?/

  # validates :raw_url, format: { with: RAW_URL_REGEX, message: 'This is not a correct format. Please copy and paste GetBravo embedded code.' }

  # def video_url
  #   getbravo_code ? "//videos.getbravo.com/embed/#{getbravo_code}/?f=1&player=simple&secret=#{getbravo_secret}" : nil
  # end

  # def thumbnail_url
  #   getbravo_code ? "http://cdn-thumbs.viddler.com/thumbnail_2_#{getbravo_code}_v2.jpg" : nil
  # end

  # private
  # def getbravo_code
  #   @getbravo_code ||= raw_url.match(RAW_URL_REGEX).to_a[1]
  # end

  # def getbravo_secret
  #   @getbravo_secret ||= raw_url.match(RAW_URL_REGEX).to_a[2]
  # end
end
