class ContactService

  EMAIL_VALIDATION_REGEX = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

  attr_accessor :form_data, :errors

  def initialize(form_data = {})
    self.form_data = form_data
  end

  def email
    form_data[:email]
  end

  def name
    form_data[:name]
  end

  def content
    form_data[:content]
  end

  def deliver(extra_data = {})
    self.errors = []
    validate_email
    validate_content
    if errors.empty?
      Resque.enqueue(SendContactEmailJob, form_data.merge(extra_data))
    end
    errors.empty?
  end

  def validate_email
    self.errors << 'Email is invalid.' unless EMAIL_VALIDATION_REGEX =~ email
  end

  def validate_content
    self.errors << 'Email content shouldn\'t be blank.' if content.blank?
  end
end
