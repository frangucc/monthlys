class PasswordsController < Devise::PasswordsController

  before_filter :set_format_to_html

  def confirmation
  end

private
  def set_format_to_html
    request.format = :html
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    passwords_confirmation_path
  end
end
