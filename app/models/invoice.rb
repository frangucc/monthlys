class Invoice < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :subscriptions
  has_many :transactions
  has_many :invoice_lines, dependent: :destroy

  validates :status, inclusion: { in: [:open, :collected, :failed, :past_due] }

  scope :non_test, joins(subscriptions: :user).where(subscriptions: { users: { is_test: false } })

  class << self
    def last_invoice
      order('created_at DESC').first
    end
  end

  # Shortcuts
  [:open, :collected, :failed, :past_due].each do |status_type|
    define_method("#{status_type}?") do
      status == status_type.to_s
    end
  end

  def to_s
    "#{self.invoice_number} - Invoice to #{user ? user.email : 'Unknown'} for $#{total_in_usd}"
  end
end
