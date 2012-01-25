class MessageGateway
  module Parser
    module CarrierAware

      def build_and_dispatch(from, to, body, carrier_id)
        if from.nil? or from.empty? or to.nil? or to.empty? or body.nil? or body.empty?
          msg = "Unable to build and dispatch message: #{from.inspect} #{to.inspect} #{body.inspect} #{carrier_id.inspect}"
          MessageGateway::SysLogger.error msg
          report_failure
          nil
        else
          report_success
          message = processor.message(from, to, body, SmsMessage)
          message.carrier_id = carrier_id
          message
        end
      end
    end
  end
end
