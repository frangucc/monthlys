class UserPreference < ActiveRecord::Base

  belongs_to :user
  belongs_to :category
  belongs_to :zipcode
  belongs_to :plan

  scope :has_status, lambda {|*args| where('status IN (?)', args) }
  scope :non_test, joins(:user).where(users: { is_test: false })

  [:active, :ready, :subscribed].each do |state_type|
    define_method("#{state_type}?") do
      state == state_type.to_s
    end
  end
end
