class Marketing::Newsletter < ActiveRecord::Base

  belongs_to :plan
  belongs_to :coupon
  has_and_belongs_to_many :best_sellers, class_name: 'Marketing::BestSeller'

  default_scope order('marketing_newsletters.subject ASC')

  mount_uploader :main_image, ImageUploader do
    process resize_to_fit: [560, nil]
  end

  mount_uploader :first_block_image, ImageUploader do
    process resize_to_fill: [156, 121]
  end

  mount_uploader :second_block_image, ImageUploader do
    process resize_to_fill: [156, 121]
  end

  mount_uploader :third_block_image, ImageUploader do
    process resize_to_fill: [156, 121]
  end

  validate :coupon_is_available_for_plan

  def coupon_is_available_for_plan
    if coupon && plan && !(coupon.available_to_all_plans? || plan.coupons.include?(coupon))
      errors.add(:coupon, ' is not available for the selected plan')
    end
  end

  def to_s
    subject
  end

end
