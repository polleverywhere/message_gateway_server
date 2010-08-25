require 'nokogiri'

class MessageGateway
  module Parser
    class Clickatell
      include Parser
      include PhoneNumber

      def call(env)
        request = Rack::Request.new(env)
        doc = Nokogiri::XML.parse(request.params['data'])
        from = sanitize_phone_number(doc.xpath('//clickmo/from').inner_text)
        to = sanitize_phone_number(doc.xpath('//clickmo/to').inner_text)
        body = doc.xpath('//clickmo/text').inner_text
        build_and_dispatch(from, to, body)
      end
    end
  end
end
