class SuperhubPlan < ActiveRecord::Base
  belongs_to :superhub_plan_group
  belongs_to :plan

  mount_uploader :image, ImageUploader do
    process resize_to_fit: [535, nil]
  end
end
