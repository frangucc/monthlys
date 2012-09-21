class Attachment < ActiveRecord::Base

  belongs_to :attachable, :polymorphic => true

  mount_uploader :image, ImageUploader do
    process :resize_to_fit => [535, nil]
  end

  default_scope order('Attachments.order ASC')

end
