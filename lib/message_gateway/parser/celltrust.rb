require 'nokogiri'

class MessageGateway
  module Parser
    class Celltrust < Base
      def call(env)
        request = Rack::Request.new(env)
        doc = Nokogiri::XML.parse(request.params['xml'])
        from = sanitize_phone_number(doc.xpath('//RecipientResponse/OriginatorAddress').inner_text)
        to = sanitize_phone_number(doc.xpath('//RecipientResponse/ServerAddress').inner_text)
        body = doc.xpath('//RecipientResponse/Data').inner_text
        build_and_dispatch(from, to, body)
      end
    end
  end
end