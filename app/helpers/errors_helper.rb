module ErrorsHelper

  def error_messages_for(object, options = {})
    return '' if object.nil?
    custom_validator = options.fetch(:custom_validator, false)

    errors = (custom_validator)? object.errors : object.errors.messages
    full_errors = full_error_messages(errors)
    render partial: 'shared/error_messages', locals: { errors: full_errors }
  end

  def full_error_messages(errors_hash)
    errors_hash.map do |field, errors|
      errors.map { |error| "#{field.to_s.humanize} #{error}" }
    end.flatten
  end
end
