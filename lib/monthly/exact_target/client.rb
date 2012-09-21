module Monthly
module ExactTarget
  class Client
    ## http://docs.code.exacttarget.com/040_XML_API/XML_API_Calls_and_Sample_Code/API_Error_Codes/Error_Code_Numbers_and_Descriptions

    API_URL = 'https://api.dc1.exacttarget.com/integrate.aspx'
    USERNAME = 'admin@monthlys.com'
    PASSWORD = '4ExactTarget!2'
    SUBSCRIBER_LISTS = {
      default: 683,
      friends: 1970
    }

    attr_accessor :source, :subscriber_list_id

    def initialize(options = {})
      self.source = options.fetch(:source, nil)
      self.subscriber_list_id = SUBSCRIBER_LISTS[source.emailable.class.subscriber_list] if source
    end

    def create_subscriber
      payload = construct_request_payload('add')
      response = send_payload(payload)
      handle(response)
    end

    def update_subscriber
      payload = construct_request_payload('edit', source.exact_target_id)
      response = send_payload(payload)
      handle(response)
    end

    def handle(response)
      document = Nokogiri::XML(response)
      subscriber_id = document.at('subscriber_description').try(:text)

      raise ResponseError, "An error occurred while trying to send a TriggeredSend: #{response}." if subscriber_id.blank?

      unless source.exact_target_id
        source.update_attribute(:exact_target_id, subscriber_id)
      end
    end

    def construct_request_payload(action, exact_target_id = nil)
      builder = Nokogiri::XML::Builder.new
      builder.exacttarget do |exact_target|
        exact_target.authorization do |authorization|
          authorization.username USERNAME
          authorization.password PASSWORD
        end
        builder.system do |system|
          system.system_name "subscriber"
          system.action action
          if action == 'add'
            system.search_type "listid"
            system.search_value self.subscriber_list_id
          else
            system.search_type "subid"
            system.search_value exact_target_id
          end
          system.values do |values|
            source.exact_target_attributes.each do |attribute, value|
              values.send(attribute, value)
            end
            if action == "add"
              values.status "active"
            end
          end
        end
      end
      builder.to_xml
    end

    def send_payload(xml, test=false)
      params = { qf: "xml", xml: xml }

      url = URI.parse(API_URL)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      param_string = params.map{|k,v| "#{k}=#{CGI::escape(v)}"}.reverse.join('&')

      request = Net::HTTP::Get.new("#{url.path}?".concat(param_string))

      response = http.start do |http|
        http.request(request)
      end

      response.body
    end
  end
end
end
