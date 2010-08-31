class MessageGateway
  module Parser
    class Simple < Base
      attr_accessor :default_to

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
        build_and_dispatch(sanitize_phone_number(from_value(req)), sanitize_phone_number(to_value(req) || default_to), body_value(req))
      end
    end
  end
end