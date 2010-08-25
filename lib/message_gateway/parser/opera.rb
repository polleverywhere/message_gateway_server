class MessageGateway
  module Parser
    class Opera < SimpleCarrier
      add_carrier_mapping :ireland_vodafone, "IRELAND.VODAFONE"
      add_carrier_mapping :ireland_o2,       "IRELAND.O2"
      add_carrier_mapping :ireland_meteor,   "IRELAND.METEOR"
      add_carrier_mapping :ireland_3,        "IRELAND.3"
      add_carrier_mapping :ireland_tesco,    "IRELAND.TESCO"
      add_carrier_mapping :ireland_bulk,     "IRELAND.BULK"

      def body_value(req)
        req['content']
      end

      def to_value(req)
        req['shortcode']
      end

      def from_value(req)
        req['msisdn']
      end

      def carrier_value(req)
        req['channel']
      end
    end
  end
end