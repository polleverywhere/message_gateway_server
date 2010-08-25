require 'nokogiri'

class MessageGateway
  module Parser
    class Mblox
      include Parser
      include PhoneNumber
      include CarrierAware
      include Util::Carrier

      add_carrier_mapping :tmobile,               "31004"
      add_carrier_mapping :att,                   "31002"
      add_carrier_mapping :sprint_pcs,            "31005"
      add_carrier_mapping :verizon_wireless,      "31003"
      add_carrier_mapping :nextel,                "31007"
      add_carrier_mapping :boost_prepay,          "31008"
      add_carrier_mapping :alltel,                "31009"
      add_carrier_mapping :cellular_one,          "31075"
      add_carrier_mapping :virgin_mobile,         "31010"
      add_carrier_mapping :us_cellular,           "31012"
      add_carrier_mapping :appalachian_wireless,  "31069"
      add_carrier_mapping :bluegrass_cellular,    "31078"
      add_carrier_mapping :boost_unlimited,       "31011"
      add_carrier_mapping :cellcom,               "31054"
      add_carrier_mapping :cellular_south,        "31052"
      add_carrier_mapping :centennial_wireless,   "31030"
      add_carrier_mapping :cincinnati_bell,       "31607"
      add_carrier_mapping :dobson_att,            "31006"
      add_carrier_mapping :immix_wireless,        "31070"
      add_carrier_mapping :revol_wireless,        "31005"
      add_carrier_mapping :unicel,                "31068"
      add_carrier_mapping :west_central_wireless, "31079"

      def call(env)
        request = Rack::Request.new(env)
        doc = Nokogiri::XML.parse(request.params['xmldata'] || request.params['XMLDATA'])
        from = sanitize_phone_number(doc.xpath('//ResponseService/ResponseList/Response/OriginatingNumber').inner_text)
        to = sanitize_phone_number(doc.xpath('//ResponseService/ResponseList/Response/Destination').inner_text)
        body = doc.xpath('//ResponseService/ResponseList/Response/Data').inner_text
        carrier_id = normalize_carrier(doc.xpath('//ResponseService/ResponseList/Response/Deliverer').inner_text)
        build_and_dispatch(from, to, body, carrier_id)
      end
    end
  end
end
