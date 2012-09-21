class PlanDocument < ActiveRecord::Base
  belongs_to :plan
  mount_uploader :file, FileUploader
end
