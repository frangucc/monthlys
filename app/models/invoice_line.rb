class InvoiceLine < ActiveRecord::Base

  belongs_to :invoice
  belongs_to :subscription

  def total_in_usd
    unit_amount_in_usd - discount_in_usd
  end

end
