require 'bureaucrat'
require 'bureaucrat/formsets'
require 'bureaucrat/quickfields'

require mp_path('mp/forms/widgets')


module MP
  module Forms
    class Form < Bureaucrat::Forms::Form
      extend Bureaucrat::Quickfields
      include MP::SinatraHelpers::AppContext

      attr_accessor :record

      def initialize(data = nil, options = {})
        if record = options.fetch(:record, nil)
          options = { initial: self.class.initial_for(record) }.merge(options)
        end

        super(data, options)

        self.record = record
        initialize_formsets(data)
      end

      def formset(name)
        @formsets.fetch(name)
      end

      def save(record)
        ActiveRecord::Base.transaction do
          populate_object(record)
          record.save(validate: false)
          save_each_formset(record)
        end
        record
      end

      def clean
        fail_validation('errors') unless @formsets.values.map(&:valid?).all?
        super
      end

      def save_each_formset(record)
        @formsets.each { |n, fs| save_formset(n, fs, record) }
      end

      def save_formset(name, formset, record)
        formset.save(record)
      end

      def initialize_formsets(data)
        @formsets = {}
      end

      def fail_validation(message)
        raise Bureaucrat::ValidationError.new(message)
      end


      def self.mark_safe(s)
        Bureaucrat::Utils::mark_safe(s)
      end

      def self.initial_for(record)
        o = Bureaucrat::Utils::StringAccessHash.new
        base_fields.keys.inject(o) do |h, field|
          value = record.send(field.to_s) if record.respond_to?(field)
          if self.respond_to?(:"initial_for_#{field}")
            value = self.send(:"initial_for_#{field}", value)
          end

          h[field.to_sym] = value

          h
        end
      end
    end


    class FormSet < Bureaucrat::Formsets::BaseFormSet
      attr_accessor :prefix

      def initialize(data = nil, options = {})
        set_defaults
        @records = options.delete(:records)
        options[:initial] = initial_for(@records) if @records && !options[:initial]
        super(data, options)
      end

      def construct_forms
        @forms = (0...total_form_count).map do |i|
          options = {}
          options[:record] = @records[i] if @records && @records[i]
          construct_form(i, options)
        end
      end

      def initial_for(records)
        keys = @form.base_fields.keys
        records.map do |r|
          keys.inject({}) do |h, k|
            h.merge(Hash[k, r.send(k)]) if r.respond_to?(k)
          end
        end
      end

      def empty_form(prefix='EMPTYFORM')
        self.form.new(nil, auto_id: @auto_id,
                           prefix: add_prefix(prefix))
      end
    end

    module RelationFormsetMixin
      def save_relation(record, rel_attr, options = {})
        return record unless cleaned_data && !cleaned_data.empty?

        id_field = options.fetch(:id_field, 'id')
        order_field = Bureaucrat::Formsets::ORDERING_FIELD_NAME
        delete_field = Bureaucrat::Formsets::DELETION_FIELD_NAME

        # Create/Update related records
        @forms.each do |f|
          data = f.cleaned_data

          next if !data || data.empty?

          values = yield(data)
          if data[id_field].blank? # create
            o = record.send(rel_attr).new(values)
          else # update
            o = record.send(rel_attr).find(data[id_field].to_i)
            values.each { |field, v| o.send("#{field}=", v) }
          end

          f.save(o)
        end

        # Delete related records
        deleted_forms.each do |form|
          id = form.send(:raw_value, id_field.to_sym)
          record.send(rel_attr).find(id).delete unless id.blank?
        end

        record
      end
    end

  module_function

    def make_formset(form_class, options = {}, &block)
      options = { can_delete: true, formset: FormSet }.merge(options)
      formset = Bureaucrat::Formsets.make_formset_class(form_class, options)
      formset.class_eval(&block)
      formset
    end
  end
end
