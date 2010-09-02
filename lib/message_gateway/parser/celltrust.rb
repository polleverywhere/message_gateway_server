require 'nokogiri'

class MessageGateway
  module Parser
    class Celltrust < Base
      include CarrierAware
      include Util::Carrier

      import_carrier_mappings CelltrustHttp

      def call(env)
        request = Rack::Request.new(env)
        doc = Nokogiri::XML.parse(request.params['xml'])
        from = sanitize_phone_number(doc.xpath('//RecipientResponse/OriginatorAddress').inner_text)
        to = sanitize_phone_number(doc.xpath('//RecipientResponse/ServerAddress').inner_text)
        body = doc.xpath('//RecipientResponse/Data').inner_text
        carrier_id = normalize_carrier(doc.xpath('//RecipientResponse/Carrier').inner_text)
        build_and_dispatch(from, to, body, carrier_id)
      end
    end
  end
end