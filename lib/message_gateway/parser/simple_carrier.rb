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

        MessageGateway::SysLogger.info "The incoming request: #{req.inspect}"
        MessageGateway::SysLogger.info "With body:\n#{req.body}"

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
