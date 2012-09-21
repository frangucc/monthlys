class TagHighlight < ActiveRecord::Base

  belongs_to :tag
  belongs_to :plan
  belongs_to :category

  mount_uploader :image, ImageUploader do
    process resize_to_fit: [258, 305]
  end

  AVAILABLE_TYPES = %w(Plan Category)

  validates :highlight_type, presence: true, inclusion: { in: AVAILABLE_TYPES }
  validates :plan, presence: true, if: proc {|th| th.highlight_type == 'Plan' }
  validates :category, presence: true, if: proc {|th| th.highlight_type == 'Category' }
  validates :tag, presence: true

  # Array of stings that match the model name
  def self.get_types
    AVAILABLE_TYPES
  end

  def get_title
    return title unless title.blank?

    case highlight_type
    when 'Plan' then plan.name
    when 'Category' then category.name
    end
  end

  def on_sale?
    false#on_sale || (highlight_type == 'Plan' && plan.on_sale?)
  end

  def get_url
    case highlight_type
    when 'Plan' then Rails.application.routes.url_helpers.plan_path(plan)
    when 'Category' then Rails.application.routes.url_helpers.category_path(category)
    end
  end
end
