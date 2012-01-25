class MessageGateway
  module Parser
    class SimpleCarrier < Simple
      include CarrierAware
      include Util::Carrier

      def carrier_value(req)
        req.params['carrier']
      end

      def call(env)
        req = Rack::Request.new(env)
        unless (request_body = req.body.read rescue '').empty?
          msg = "The incoming request: #{req.inspect} with body: #{request_body}"
          MessageGateway::SysLogger.info msg
        end
        req.body.rewind

        build_and_dispatch(
          sanitize_phone_number(from_value(req)),
          sanitize_phone_number(to_value(req)) || default_to,
          body_value(req),
          normalize_carrier(carrier_value(req))
        )
      end
    end
  end
end
