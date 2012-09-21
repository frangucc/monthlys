require "bureaucrat/utils"
require "bureaucrat/widgets"

module Bureaucrat::Widgets
  # FIXME: Replacing the ClearableFileInput#render from Bureaucrat with this
  # because it's hard to extend. We need to get a patch into Bureaucrat for
  # this (mainly, allow for a more flexible #render method).
  class ClearableFileInput < FileInput
    def initial(value)
      '<a http="%s">%s</a>' % [escape(value.url), escape(value.to_s)]
    end

    def render(name, value, attrs = nil)
      substitutions = {
        initial_text: initial_text,
        input_text: input_text,
        clear_template: '',
        clear_checkbox_label: clear_checkbox_label
      }
      template = '%(input)s'
      substitutions[:input] = super(name, value, attrs)

      if value && value.respond_to?(:url) && value.url
        template = template_with_initial
        substitutions[:initial] = initial(value)
        unless is_required
          checkbox_name = clear_checkbox_name(name)
          checkbox_id = clear_checkbox_id(checkbox_name)
          substitutions[:clear_checkbox_name] = conditional_escape(checkbox_name)
          substitutions[:clear_checkbox_id] = conditional_escape(checkbox_id)
          substitutions[:clear] = CheckboxInput.new.
            render(checkbox_name, false, {id: checkbox_id})
          substitutions[:clear_template] =
            format_string(template_with_clear, substitutions)
        end
      end

      mark_safe(format_string(template, substitutions))
    end
  end
end
