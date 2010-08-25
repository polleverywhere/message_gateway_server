class MessageGateway
  module Parser
    class Txtnation < Simple
      attr_accessor :prefix
      
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
