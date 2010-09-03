class MessageGateway
  module Parser
    class MobileMessenger < Simple
      def body_value(req)
        @prefix ? req.params['message'].gsub(/^#{Regexp.quote(@prefix)} /, '') : req.params['message']
      end
      
      def from_value(req)
        req.params['number']
      end

      def to_value(req)
        req.params['shortcode']
      end
    end
  end
end
