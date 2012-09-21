class OptionRecurlyCode < ActiveRecord::Base

  belongs_to :option
  belongs_to :plan_recurrence

end
