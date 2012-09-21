class SuperhubPlanGroup < ActiveRecord::Base
  has_many :superhub_plans

  def self.get_group_types
    { primary: 'Primary highlight',
      secondary: 'Secondary highlight',
      tertiary: 'Tertiary highlight' }
  end

  def get_label_display
    { featured: 'Featured',
      new: 'New',
      local: 'Local',
      sale: 'On Sale'}[label.to_sym]
  end
end
