class CategoryGroup < ActiveRecord::Base

  has_many :categories, :dependent => :nullify
  has_many :plans, through: :categories

  mount_uploader :image, ImageUploader do
    process resize_to_fill: [900, 160]
  end

  validates :name, :image, :presence => true
end
