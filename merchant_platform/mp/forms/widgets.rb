require 'date'

module Bureaucrat
  module Widgets
    class MultiCombo < Select
      def render(name, value, attrs=nil)
        value = value || {}
        out = @attrs.delete(:choices_sets).map do |choice_name, choices|
          super("#{name}[#{choice_name}]", value[choice_name.to_sym] || '',
                attrs, choices)
        end.join(' ')

        mark_safe(out)
      end
    end

    class ModelMultipleChoice < TextInput
      def render(name, value, attrs=nil)
        @model_class ||= @attrs.delete(:model)
        @model_field ||= @attrs.delete(:model_field)

        value = value.map do |val|
          if val.is_a?(@model_class) then val.send(@model_field)
          else val
          end
        end.join(', ') if value.is_a? Array

        super(name, value, attrs)
      end
    end

    class HiddenModelMultipleChoice < ModelMultipleChoice
      def input_type
        'hidden'
      end
    end

    class ImageInput < ClearableFileInput
      def template_with_initial
        '<div class="imagepreview">%(initial)s %(input)s</div>'
      end

      def initial(value)
        '<img src="%s" alt="Uploaded Image">' % escape(value.url)
      end

      def has_changed?(initial, data)
        !data.nil?
      end
    end

    class DocumentFileInput < ClearableFileInput
      def template_with_initial
        '%(input)s<br /><span class="initial">%(initial_text)s: %(initial)s</span>'
      end

      def render(name, value, attrs = nil)
        substitutions = {
          initial_text: initial_text,
          clear_template: '',
          clear_checkbox_label: clear_checkbox_label
        }
        template = '%(input)s'
        substitutions[:input] = FileInput.new.render(name, value, attrs)

        if value && value.respond_to?(:url) && value.url
          template = template_with_initial
          substitutions[:initial] = '<a href="%s">%s</a>' % [escape(value.url),
                                                             escape(value.to_s.split('/').last)]
          unless is_required
            checkbox_name = clear_checkbox_name(name)
            checkbox_id = clear_checkbox_id(checkbox_name)
            substitutions[:clear_checkbox_name] = conditional_escape(checkbox_name)
            substitutions[:clear_checkbox_id] = conditional_escape(checkbox_id)
            substitutions[:clear] = CheckboxInput.new.
              render(checkbox_name, false, {id: checkbox_id})
            substitutions[:clear_template] =
              Utils.format_string(template_with_clear, substitutions)
          end
        end

        mark_safe(Utils.format_string(template, substitutions))
      end
    end

    class DateWidget < TextInput
      def render(name, value, attrs = nil)
        # Render a three-select widget for day/month/year
        today = Date.today
        value = value || today

        days = (1...31).map{|d| [d, d]}
        months = Date::MONTHNAMES.each_with_index.map{|m, i|
          [i, m]
        }.slice(1..-1)
        years = (today.year .. today.year + 10).map{|y| [y, y]}

        day = Select.new(nil, choices: days)
                    .render("#{name}[day]", value.day, attrs)
        month = Select.new(nil, choices: months)
                      .render("#{name}[month]", value.month, attrs)
        year = Select.new(nil, choices: years)
                     .render("#{name}[year]", value.year, attrs)

        "<div class='date-field'>#{day} #{month} #{year}</div>"
      end
    end
  end

  module Fields
    class MultiSelectFields < Field
      def initialize(choices_sets=[], *args)
        @choices_sets = choices_sets
        super(*args)
      end

      def widget_attrs(widget)
        { choices_sets: @choices_sets }
      end

      def default_widget
        Widgets::MultiCombo
      end
    end

    class ModelInstanceMultiselect < CharField
      attr_accessor :model, :model_field

      def initialize(model, *args)
        @model = model
        @model_field = (args.delete(:model_field) || :id).to_sym
        super(*args)
      end

      def prepare_value(value)
        return [] unless value
        if value.respond_to?(:map)
          value.map { |val| val.send(@model_field) if val.is_a? @model }
        else # String
          value.split(/\s*,\s*/)
        end.compact
      end

      def to_object(value)
        value.split(/\s*,\s*/).map do |val|
          @model.send(:"find_by_#{@model_field}", val) unless val.empty?
        end.compact
      end

      def widget_attrs(widget)
        { model: @model,
          model_field: @model_field }
      end

      def default_widget
        Widgets::ModelMultipleChoice
      end

      def default_hidden_widget
        # Initialize the hidden widget since bureaucrat fails to set the
        # attributes on hidden widget
        hidden = Widgets::HiddenModelMultipleChoice.new
        hidden.attrs.update(widget_attrs(hidden))
        hidden.is_required = @required

        hidden
      end
    end

    class ModelInstance < ChoiceField
      attr_accessor :model, :model_field

      def initialize(model, options={})
        @model = model
        @model_field = (options.delete(:model_field) || :id).to_sym
        @model_description = (options.delete(:model_description) || :to_s).to_sym

        choices = @model.all.map{|m|
          [m.send(@model_field).to_s, m.send(@model_description)]
        }
        choices = ([['', 'Select a choice']] + choices) unless options[:required]

        super(choices, options)
      end

      def prepare_value(value)
        value = value.send(@model_field).to_s if value && value.is_a?(@model)

        value
      end

      def to_object(value)
        value = super(value)
        @model.send(:"find_by_#{@model_field}", value) unless value.empty?
      end

      def valid_value?(value)
        value = value.send(@model_field).to_s if value.is_a?(@model)
        @choices.any?{|k, v| value == k.to_s}
      end
    end

    class DateField < CharField
      def to_object(value)
        Date.new(value[:year].to_i, value[:month].to_i, value[:day].to_i)
      end

      def default_widget
        Widgets::DateWidget
      end
    end
  end
end
