class MessageGateway
  module Parser
    include PhoneNumber

    autoload :Base,          'message_gateway/parser/base'
    autoload :CarrierAware,  'message_gateway/parser/carrier_aware'
    autoload :Simple,        'message_gateway/parser/simple'
    autoload :SimpleCarrier, 'message_gateway/parser/simple_carrier'

    # impls
    autoload :Celltrust,     'message_gateway/parser/celltrust'
    autoload :Clickatell,    'message_gateway/parser/clickatell'
    autoload :Mblox,         'message_gateway/parser/mblox'
    autoload :MxTelecom,     'message_gateway/parser/mx_telecom'
    autoload :Opera,         'message_gateway/parser/opera'
    autoload :Txtnation,     'message_gateway/parser/txtnation'
    autoload :Textmarks,     'message_gateway/parser/textmarks'
    autoload :UnwiredAppeal, 'message_gateway/parser/unwired_appeal'

    attr_accessor :processor

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
        log.error "Unable to build and dispatch message: #{from.inspect} #{to.inspect} #{body.inspect} #{carrier_id.inspect}"
        report_failure
        nil
      else
        report_success
        message = processor.message(from, to, body)
        message.carrier_id = carrier_id if message.respond_to?(:carrier_id=)
        message
      end
    rescue
      log.error "#{$!.message}\n#{$!.backtrace.join("\n")}"
    end
  end
end
