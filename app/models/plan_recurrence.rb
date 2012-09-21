class PlanRecurrence < ActiveRecord::Base

  has_many :subscriptions
  has_many :option_recurly_codes
  belongs_to :plan

  # Remove this validations after the MP is implemented
  validates :plan, :amount, :recurrence_type, :presence => true

  # Scopes
  scope :active, where(is_active: true)

  def pretty_explanation
    "$#{pretty_amount} #{billing_desc}"
  end

  def pretty_amount
    sprintf('%.02f', amount)
  end

  def monthly_cost
    recurrence[:monthly_cost].call(amount)
  end

  def service_cost
    recurrence[:service_cost].call(amount)
  end

  def shipping_desc
    recurrence[:shipping_desc]
  end

  def billing_desc
    recurrence[:billing_desc]
  end

  def billing_recurrence_in_words
    recurrence[:billing_recurrence]
  end

  def services_per_billing_cycle
    recurrence[:services_per_billing_cycle]
  end

  def billing_cycle
    recurrence[:billing_interval_length].send(recurrence[:billing_interval_unit])
  end

  def billing_cycle_in_words
    if billing_cycle == 1.month
      'month to month'
    else
      billing_cycle.inspect.singularize
    end
  end

  # Calculates the days between shipping cycles.
  #
  # Returns the amount of days.
  def days_per_shipping_cycle
    interval = recurrence[:billing_interval_length].send(recurrence[:billing_interval_unit])
    interval / services_per_billing_cycle.days
  end

  private

  def recurrence
    Recurrence.get(recurrence_type)
  end
end
