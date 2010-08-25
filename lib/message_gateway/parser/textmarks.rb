class MessageGateway
  module Parser
    class Textmarks < Simple
      def body_value(req)
        req.params['body']
      end
      
      def from_value(req)
        req.params['from']
      end

      def to_value(req)
        req.params['to']
      end
    end
  end
end
