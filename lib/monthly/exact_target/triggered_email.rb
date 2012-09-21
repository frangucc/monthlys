module Monthly
  module ExactTarget
    class ResponseError < StandardError; end

    class TriggeredEmail

      API_URL = 'https://api.dc1.exacttarget.com/integrate.aspx'
      USERNAME = 'admin@monthlys.com'
      PASSWORD = '4ExactTarget!2'
      ## http://docs.code.exacttarget.com/020_Web_Service_Guide/Triggered_Email_Scenario_Guide_For_Developers

      attr_accessor :email_key, :email_address, :attributes, :payload

      def initialize(email_address, triggered_email_key, options={})
        raise "[ExactTarget] Email address is invalid." unless email_address.present?

        if Rails.env.development? && defined?(Monthly::Config::DEVELOPMENT_REDIRECT_EMAIL)
          self.email_address = Monthly::Config::DEVELOPMENT_REDIRECT_EMAIL
        else
          self.email_address = email_address
        end
        self.email_key = triggered_email_key
        self.attributes = options[:attributes] || {}
        self.payload = build_xml
      end

      def deliver!
        return if Rails.env.development? && !defined?(Monthly::Config::DEVELOPMENT_REDIRECT_EMAIL)
        client = Monthly::ExactTarget::Client.new
        response = client.send_payload(payload)

        handle_response(response)

        response
      end

      private
      def handle_response(response)
        xml = Nokogiri::XML(response)

        triggered_send_info = xml.at('triggered_send_info').try(:text)

        if triggered_send_info != 'Triggered Send was added successfully'
          error_title = xml.at('error_description').try(:text)
          error_detail = xml.at('error_detail').try(:text)
          if error_title && error_detail
            raise ResponseError, "An error occurred while trying to send a TriggeredSend: #{error_title}. Detail: #{error_detail}"
          else
            raise ResponseError, "An UNKNOWN error occurred while trying to send a TriggeredSend: #{response.gsub(/(\r\n|\n|\r)/,'')}"
          end
        end
      end

      def build_xml
        builder = Nokogiri::XML::Builder.new
        builder.exacttarget do |exact_target|
          exact_target.authorization do |authorization|
            authorization.username USERNAME
            authorization.password PASSWORD
          end
          exact_target.system do |system|
            system.system_name "triggeredsend"
            system.action "add"
            system.TriggeredSend({
              "xmlns:xsi" => 'http://www.w3.org/2001/XMLSchema-instance',
              "xmlns:xsd" => 'http://www.w3.org/2001/XMLSchema',
              "xmlns" => 'http://exacttarget.com/wsdl/partnerAPI'
            }) do |triggered_send|
              triggered_send.TriggeredSendDefinition do |triggered_send_definition|
                triggered_send_definition.CustomerKey email_key
              end
              triggered_send.Subscribers do |subscribers|
                subscribers.EmailAddress email_address
                subscribers.SubscriberKey email_address
                unless attributes.empty?
                  subscribers.Attributes do |attributes|
                    @attributes.each do |key, value|
                      attributes.Name key.to_s
                      attributes.Value value
                    end
                  end
                end
              end
            end
          end
        end
        builder.to_xml
      end

    end
  end
end
