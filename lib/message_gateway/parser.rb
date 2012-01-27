class MessageGateway

  # Each mobile agreegator has different formats of which it sends data to us (from a mobile originating)
  # SMS message.
  #
  # This class is to incoming messages what Processor is to outgoing messages
  module Parser
    include PhoneNumber
    include Logging

    autoload  :Base,             'message_gateway/parser/base'
    autoload  :CarrierAware,     'message_gateway/parser/carrier_aware'
    autoload  :Simple,           'message_gateway/parser/simple'
    autoload  :SimpleCarrier,    'message_gateway/parser/simple_carrier'

    # impls
    autoload  :Celltrust,        'message_gateway/parser/celltrust'
    autoload  :CelltrustHttp,    'message_gateway/parser/celltrust_http'
    autoload  :Clickatell,       'message_gateway/parser/clickatell'
    autoload  :Mblox,            'message_gateway/parser/mblox'
    autoload  :MobileMessenger,  'message_gateway/parser/mobile_messenger'
    autoload  :Opera,            'message_gateway/parser/opera'
    autoload  :Txtnation,        'message_gateway/parser/txtnation'
    autoload  :Twilio,           'message_gateway/parser/twilio'
    autoload  :Textmarks,        'message_gateway/parser/textmarks'
    autoload  :UnwiredAppeal,    'message_gateway/parser/unwired_appeal'
    autoload  :MxTelecom,        'message_gateway/parser/mx_telecom'

    attr_accessor :processor

    def gateway
      processor.gateway
    end

    def report_success
      @success_count ||= 0
      @success_count += 1
    end

    def report_failure
      @failure_count ||= 0
      @failure_count += 1
    end

    def success_count
      (@success_count ||= 0)
    end

    def failure_count
      (@failure_count ||= 0)
    end

    def build_and_dispatch(from, to, body)
      if from.empty? || to.empty? || body.empty?
        err_base = "Unable to build and dispatch message: "
        vals = [from, to, body].map{ |v| v.inspect }.join ' '
        MessageGateway::SysLogger.error "#{err_base} #{vals}"
        report_failure
        nil
      else
        report_success
        message = processor.message(from, to, body)
        message.carrier_id = carrier_id if message.respond_to?(:carrier_id=)
        message
      end
    rescue
      msg_and_backtrace = "#{$!.message}\n#{$!.backtrace.join("\n")}"
      MessageGateway::SysLogger.error "build_and_dispatch rescue: #{msg_and_backtrace}"
    end
  end
end
