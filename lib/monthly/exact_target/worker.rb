module Monthly
  module ExactTarget
    class Worker
      @queue = :mail_queue

      def self.perform(action, source_type, source_id)
        job = Job.new(source_type: source_type, source_id: source_id)
        job.send(action)
      end
    end

    class Job
      attr_accessor :source

      def initialize(options = {})
        self.source = options[:source_type].constantize.find(options[:source_id])
      end

      # this is the action that is responsible for updating
      # the email recipients table with the appropriate attributes
      # as defined by the acts_as_exact_target_subscriber call
      def update_email_recipient
        source.try(:update_email_recipient)
      end

      # this is the action that is responsible for connecting to the
      # exact target API, and creating or updating the object
      # in the exact target subscribers table
      def update_api
        source.try(:sync_with_api)
      end
    end
  end
end
