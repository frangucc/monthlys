class AdminActivity < ActiveRecord::Base

  belongs_to :object, polymorphic: :true
  belongs_to :admin_user

  serialize :previous_attributes, Hash
  serialize :new_attributes, Hash

  scope :latest, order('admin_activities.created_at DESC').limit(20)

  before_create :remove_equal_attributes

  def remove_equal_attributes
    equal_attributes = []

    previous_attributes.each do |field, val|
      equal_attributes << field if new_attributes[field] == val
    end

    equal_attributes.each do |field|
      previous_attributes.delete(field)
      new_attributes.delete(field)
    end
  end
end
