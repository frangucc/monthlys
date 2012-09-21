class Faq < ActiveRecord::Base

  has_and_belongs_to_many :merchants

  validates_presence_of :question, :answer
  default_scope order('faqs.order ASC')

  def to_s
    self.question
  end
end
