class MessageGateway
  class Sender
    include Logging
    
    autoload :Celltrust,     'message_gateway/sender/celltrust'
    autoload :Clickatell,    'message_gateway/sender/clickatell'
    autoload :Mblox,         'message_gateway/sender/mblox'
    autoload :MxTelecom,     'message_gateway/sender/mx_telecom'
    autoload :Opera,         'message_gateway/sender/opera'
    autoload :Txtnation,     'message_gateway/sender/txtnation'
    autoload :UnwiredAppeal, 'message_gateway/sender/unwired_appeal'
    autoload :Smtp,          'message_gateway/sender/smtp'

    attr_accessor :name, :from, :default_from

    def init
      yield self if block_given?
    end

    def start
      verify
      puts "Starting sender #{name} with #{self.class}"
    end

    def verify
    end

    def verify_params(*params)
      params.each do |p|
        raise("`#{p}' cannot be blank") unless __send__(p.to_sym) && !__send__(p.to_sym).empty?
      end
    end

    def defer_success_on_200(http)
      defer(http) { http.response_header.status == 200 }
    end

    def add_errback(http)
      http.errback do |err|
        # logging ERROR
      end
    end
    
    def call(message)
      verify
      send(message)
    end
    
    def defer(http, &blk)
      d = EM::DefaultDeferrable.new
      http.callback { blk.call ? d.succeed : d.fail("#{http.response_header.status}\n#{http.response}") }
      http.errback  { |err| d.fail(err) }
      d
    end
    
  end
end
