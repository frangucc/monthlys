module Monthly
  module ExactTarget
    module Emailable
      extend ActiveSupport::Concern

      included do
        has_one :email_recipient, as: :emailable
      end

      def update_email_recipient
        if self.email_recipient.present?
          self.email_recipient.sync_with_emailable
          self.email_recipient.save
        else
          self.email_recipient = EmailRecipient.create(emailable: self, email: self.email)
        end
      end

      def schedule_email_recipient_update
        if Rails.env.test?
          Monthly::ExactTarget::Worker.perform(:update_email_recipient, self.class.to_s, self.id)
        else
          Resque.enqueue(Monthly::ExactTarget::Worker, :update_email_recipient, self.class.to_s, self.id)
        end
      end

      # Override this method in your class if you want something different
      #
      # NOTE: Profile attributes which have spaces convert to double underscore
      #
      # NOTE: These attributes have to be defined in the Exact Target Administration center
      #       prior to being available on the subscriber profile, or as variables in interpolated
      #       email sending
      def default_exact_target_attributes
        {
          subscriber__type: self.send(:exact_target_subscriber_type),
          email__address: self.send(:email)
        }
      end

      def exact_target_attributes_list
        self.class.exact_target_attributes
      end

      # TODO
      # We should modify the configuration
      def exact_target_attributes
        exact_target_attributes_list.each_with_object(default_exact_target_attributes) do |attribute, attr_hash|
          et_key = attribute.to_s.gsub(/_/, '__')
          attr_hash[et_key] = self.send(attribute)
        end
      end

      def exact_target_subscriber_type
        self.class.to_s.downcase
      end

      # NOTE:
      #
      # If you want to use dates in interpolation, you will need to format them through this helper
      #   http://docs.code.exacttarget.com/020_Web_Service_Guide/Technical_Articles/Incoming_Date_Normalization
      def format_date(date)
        (date.blank?)? '' : date.strftime("%Y-%m-%dT%TZ")
      end

      ## Booleans are sent across as 1 and 0
      def format_boolean(boolean)
        (boolean == true)? 1 : 0
      end

      module ClassMethods
        def acts_as_exact_target_subscriber(options = {})
          class << self
            attr_accessor :exact_target_attributes
            attr_accessor :subscriber_list
          end

          self.subscriber_list = options.fetch(:subscriber_list, :default)
          self.exact_target_attributes = options.fetch(:attributes)

          # after_commit :schedule_email_recipient_update
        end
      end
    end
  end
end