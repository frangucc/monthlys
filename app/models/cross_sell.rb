class CrossSell < ActiveRecord::Base
  belongs_to :category
  belongs_to :related_category, :class_name => "Category"
end
