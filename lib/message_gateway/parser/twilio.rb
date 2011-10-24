class MessageGateway
  module Parser
    class Twilio < Simple

      # NOTE: Twilio does not have access to carrier code information as of this writing.
      # Source: <http://getsatisfaction.com/twilio/topics/how_to_get_cell_phone_carrier_via_sms>
      # WD-rpw 10-10-2011

      def body_value(req)
        req.params['Body']
      end

      def from_value(req)
        req.params['From']
      end

      def to_value(req)
        req.params['To']
      end

    end #class Twilio
  end
end
