class MessageGateway
  module Parser
    class Twilio < Simple
    
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
