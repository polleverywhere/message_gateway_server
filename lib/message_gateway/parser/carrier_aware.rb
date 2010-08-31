class MessageGateway
  module Parser
    module CarrierAware
      
      def build_and_dispatch(from, to, body, carrier_id)
        if from.nil? or from.empty? or to.nil? or to.empty? or body.nil? or body.empty?
          log.error "Unable to build and dispatch message: #{from.inspect} #{to.inspect} #{body.inspect} #{carrier_id.inspect}"
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