class MessageGateway
  module Parser
    class Simple
      include Parser
      include PhoneNumber

      def from_value(req)
        req.params['sender']
      end

      def to_value(req)
        req.params['receiver']
      end

      def body_value(req)
        req.params['body']
      end

      def call(env)
        req = Rack::Request.new(env)
        build_and_dispatch(sanitize_phone_number(from_value(req)), sanitize_phone_number(to_value(req)), body_value(req))
      end
    end
  end
end