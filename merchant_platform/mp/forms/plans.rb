require mp_path('mp/forms/base')

module MP
  module Forms

    class Plan < Form
      TYPE_CHOICES = PlanType.get_all_types.map {|k,v| [k, v[:name]] }
      SUB_TYPE_CHOICES = PlanType.get_all_subtypes.map {|k, v| [k, v[:name]] }

      # Basic details
      string :name, label: 'Name of the plan'
      text :description
      string :marketing_phrase, label: 'Tagline'
      field :plan_type, Bureaucrat::Fields::MultiSelectFields.new([
              [:type, TYPE_CHOICES],
              [:sub_type, SUB_TYPE_CHOICES]
            ])
      field :categories, Bureaucrat::Fields::ModelInstanceMultiselect.new(Category)
      field :details, Bureaucrat::Fields::CharField.new(widget: Bureaucrat::Widgets::Textarea.new({
        rows: '4',
      }), required: false)
      file :thumbnail, label: 'Thumbnail Image', widget: Bureaucrat::Widgets::ImageInput
      file :icon, label: 'Icon Image', widget: Bureaucrat::Widgets::ImageInput
      text :terms, label: 'Terms &amp; Conditions', required: false,
           help_text: 'This info will be used for all new plans. You may edit.'
      text :fine_print, label: 'Fine Print', required: false,
           help_text: 'This info will be used for all new plans. You may edit.'
      boolean :extra_notes, label: 'Allow special order notes.', required: false
      ::Recurrence.data.each do |k, opts|
        boolean :"recurrence_#{k}", required: false
        decimal :"recurrence_#{k}_amount", label: opts[:name], required: false
      end

      def field_groups
        billing_fields = ::Recurrence.data.map do |k, opts|
          [:"recurrence_#{k}", :"recurrence_#{k}_amount"]
        end

        {
          basic: [:name, :description, :marketing_phrase, :plan_type,
                  :categories, :details, :thumbnail, :icon, :terms,
                  :fine_print, :extra_notes],
          billing: billing_fields
        }
      end

      def self.initial_for(record)
        data = super(record)

        st = data[:plan_type].to_sym
        data[:plan_type] = {
          type: PlanType.get_type_key(st),
          sub_type: st
        }

        record.plan_recurrences.each do |pr|
          data[:"recurrence_#{pr.recurrence_type}"] = pr.is_active
          data[:"recurrence_#{pr.recurrence_type}_amount"] = pr.amount
        end if record

        data
      end

      def save(plan)
        ActiveRecord::Base.transaction do
          plan.merchant_id = appcontext.current_merchant.id
          plan = super(plan)
          save_recurrences(plan)
        end

        plan
      end

      def save_recurrences(plan)
        saved_prs = plan.plan_recurrences.inject({}) do |h, pr|
          h.merge({ pr.recurrence_type.to_sym => pr })
        end

        ::Recurrence.data.each do |type, opts|
          pr = if saved_prs.has_key?(type) then saved_prs[type]
               elsif cleaned_data["recurrence_#{type}"] then plan.plan_recurrences.new
               else nil
               end

          unless pr.nil?
            pr.is_active = cleaned_data["recurrence_#{type}"]
            pr.amount = cleaned_data["recurrence_#{type}_amount"]
            pr.recurrence_type = type
            pr.save(validate: false)
          end
        end
      end

      def initialize_formsets(data)
        # Initials
        if record
          documents = record.plan_documents.to_a
          questions = record.option_groups.to_a
          attachments = record.attachments.to_a
        else
          documents = questions = attachments = nil
        end

        # Formsets
        @formsets = {
          documents: PlanDocumentFormset.new(data, prefix: 'documents',
                                                   records: documents),
          gallery: GalleryFormset.new(data, prefix: 'gallery',
                                            records: attachments),
          questions: QuestionFormset.new(data, prefix: 'questions',
                                               records: questions)
        }
      end

      # Validations

      def clean_plan_type
        t = cleaned_data[:plan_type][:type]
        st = cleaned_data[:plan_type][:sub_type]

        if !PlanType.valid_subtype?(t, st)
          fail_validation('Invalid subtype for selected type')
        end

        cleaned_data[:plan_type] = st # We just care about the subtype
      end

      ::Recurrence.data.each do |k, opts|
        send(:define_method, :"clean_recurrence_#{k}_amount") do
          is_active = cleaned_data.fetch("recurrence_#{k}")
          amount = cleaned_data.fetch("recurrence_#{k}_amount")

          if is_active && amount.nil?
            fail_validation('You must specify an amount')
          end

          amount
        end
      end
    end


    ########################################################################
    # Formset forms
    ########################################################################

    class PlanDocument < Form
      string :id, required: false
      hide :id
      string :name
      text :description, required: false
      file :file, label: 'Document', widget: Bureaucrat::Widgets::DocumentFileInput
    end

    class Gallery < Form
      string :id, required: false
      hide :id
      file :image, label: 'Image', widget: Bureaucrat::Widgets::ImageInput,
                   required: false
    end

    class Question < Form
      IMPACT_ON_PRICE_CHOICES = [
        [nil, '----'],
        [:per_service, 'Recurring amount per service'],
        [:per_billing, 'Recurring amount per billing cycle'],
        [:onetime, 'One time fee'],
        [:nocharge, 'No extra charge']
      ]

      string :id, required: false
      hide :id
      string :description, label: 'Question'
      choice :option_type, IMPACT_ON_PRICE_CHOICES, label: 'Impact on the price'
      boolean :allow_multiple, label: 'Allow multiple options selection',
              required: false

      def initialize_formsets(data)
        @formsets = {
          answers: AnswerFormset.new(data, prefix: "#{@prefix}-answers",
                                     records: record ? record.options.to_a : nil)
        }
      end
    end

    class Answer < Form
      string :id, required: false
      hide :id
      string :title, label: 'Answer'
      text :description, required: false
      decimal :amount, label: 'Price'
      #file :image
    end


    ########################################################################
    # Formsets
    ########################################################################

    PlanDocumentFormset = make_formset(PlanDocument, extra: 0) do
      include RelationFormsetMixin

      def save(record)
        save_relation(record, :plan_documents) do |data|
          values = { name: data[:name],
                     description: data[:description],
                     plan_id: record.id }
          values[:file] = data[:file].tempfile \
              if data[:file].is_a? Bureaucrat::TemporaryUploadedFile

          values
        end
      end
    end

    GalleryFormset = make_formset(Gallery, extra: 0) do
      include RelationFormsetMixin

      def save(record)
        save_relation(record, :attachments) do |data|
          # Return the tempfile value, otherwise Carrierwave fails, maybe
          # because Bureaucrat::TemporaryUploadedFile doesn't support the
          # needed file API
          if data[:image].is_a? Bureaucrat::TemporaryUploadedFile
            { image: data[:image].tempfile }
          else
            {}
          end
        end
      end
    end

    QuestionFormset = make_formset(Question, extra: 0) do
      include RelationFormsetMixin

      def save(plan)
        save_relation(plan, :option_groups) do |data|
          { description: data[:description],
            option_type: data[:option_type],
            allow_multiple: data[:allow_multiple],
            plan_id: plan.id }
        end
      end
    end

    AnswerFormset = make_formset(Answer, extra: 0) do
      include RelationFormsetMixin

      def save(option_group)
        save_relation(option_group, :options) do |data|
          { title: data[:title],
            description: data[:description],
            amount: data[:amount],
            option_group_id: option_group.id }
        end
      end
    end
  end
end
