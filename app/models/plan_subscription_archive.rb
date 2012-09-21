class PlanSubscriptionArchive < ActiveRecord::Base

  belongs_to :plan

  validates_presence_of :plan, :sent_on, :image, :title

  mount_uploader :image, ImageUploader do
    process resize_to_fit: [535, nil]
  end

  default_scope order('sent_on DESC')

  def image_url
    image.url
  end

  def sent_on_display
    sent_on.strftime('%m/%d/%y')
  end

end
