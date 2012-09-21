class Transaction < ActiveRecord::Base

  belongs_to :invoice
  has_one :user, through: :invoice
  attr_accessor :disable_shipping

  validates_presence_of :invoice, :amount
  validate :amount_is_minor_than_total, :invoice_has_one_transaction

  def amount_is_minor_than_total
    if !amount || amount > invoice.total_in_usd
      errors.add(:amount, 'can\'t be greater than the invoice total')
    end
  end

  def invoice_has_one_transaction
    if invoice.transactions.count > 0
      errors.add(:invoice, 'a refund for this invoice has already been created')
    end
  end

  def associated_plan
    invoice.subscriptions.first.try(:plan)
  end

end
