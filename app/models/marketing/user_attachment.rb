class Marketing::UserAttachment < ActiveRecord::Base

  belongs_to :user

  mount_uploader :image, ImageUploader do
    process resize_to_fit: [535, nil]
  end

  validates :name, presence: true, unless: :user
  validates :email, presence: true, format: { with: Monthly::Application.config.app_config.email_validation_regex }, unless: :user
  validates :image, presence: true
  validates :attachment_type, presence: true
end
