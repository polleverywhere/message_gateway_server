class MessageGateway

  # The subclass interface for mobile terminating (aka: outbound) traffic.
  #
  # TO CREATE AN INTERFACE FOR A NEW MOBILE AGGREGATOR:
  #
  #  1. Create your class structure as follows:
  #    class MessageGateway
  #      class Sender
  #         class MyGatewayName < Sender
  #            ...
  #          end
  #       end
  #    end
  #
  # 2. Your subclass *must* implement the following protocol (quack like the following duck):
  #    * def send(message)
  #       - This method sends the actual message to the Mobile Aggregator. Do whatever HTTP request
  #           you need to do, with whatever data elements, that the Mobile Aggregator demands.
  #       - This method must return a EventMachine defered object... ideally by calling Sender#defer_success_on_200
  #
  #    * def verify
  #
  # 3. add a new autoload line to sender.rb (this file)
  #
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
