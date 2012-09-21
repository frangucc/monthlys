class Tag < ActiveRecord::Base

  has_and_belongs_to_many :plans
  scope :featured, where(is_featured: true)

  mount_uploader :header_image, ImageUploader do
    process resize_to_fill: [900, 160]
  end

  before_save :update_slug

  TAGS_KEYWORD_FORMAT_REGEX = /\A[\d\w][\d\w\-]+[\w\d]\z/
  validates :header_image, presence: true
  validates :keyword, uniqueness: { case_sensitive: false }

  default_scope order('tags.order ASC')

  def to_s
    keyword
  end

  def to_param
    slug
  end

  def update_slug
    if slug.blank?
      self.slug = SlugGeneratorService.new(keyword).generate_slug do |the_slug|
        Tag.where(slug: the_slug).where('tags.id != ?', self.id).any?
      end
    end
  end
end
