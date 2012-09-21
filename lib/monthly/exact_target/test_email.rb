module Monthly
  module ExactTarget
    class TestEmail

      API_URL = 'https://api.dc1.exacttarget.com/integrate.aspx'
      USERNAME = 'admin@monthlys.com'
      PASSWORD = '4ExactTarget!2'

      attr_accessor :email, :payload

      def initialize
        self.email = 'federico.bana@monthlys.com'
        self.payload = build_xml
        deliver!
      end

      def deliver!
        client = Monthly::ExactTarget::Client.new
        response = client.send_payload(payload)
      end

      def build_xml
        builder = Nokogiri::XML::Builder.new

        builder.exacttarget do |exacttarget|
          exacttarget.authorization do |authorization|
            authorization.username USERNAME
            authorization.password PASSWORD
          end
          exacttarget.system do |system|
            system.system_name "email"
            system.action "add"
            system.Email({
              "xmlns:xsi" => 'http://www.w3.org/2001/XMLSchema-instance', 
              "xmlns:xsd" => 'http://www.w3.org/2001/XMLSchema', 
              "xmlns" => 'http://exacttarget.com/wsdl/partnerAPI'
            }) do |email|
              email.Name "email_created_from_api"
              email.ContentAreas do |content_areas|
              end
            end
          end
        end
        builder.to_xml
      end

    end
  end
end