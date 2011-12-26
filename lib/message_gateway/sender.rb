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

    autoload :Celltrust,      'message_gateway/sender/celltrust'
    autoload :Clickatell,     'message_gateway/sender/clickatell'
    autoload :Mblox,          'message_gateway/sender/mblox'
    autoload :MobileMessenger,'message_gateway/sender/mobile_messenger'
    autoload :MxTelecom,      'message_gateway/sender/mx_telecom'
    autoload :Opera,          'message_gateway/sender/opera'
    autoload :Smtp,           'message_gateway/sender/smtp'
    autoload :Twilio,         'message_gateway/sender/twilio'
    autoload :Txtnation,      'message_gateway/sender/txtnation'
    autoload :UnwiredAppeal,  'message_gateway/sender/unwired_appeal'

    attr_accessor :name, :from, :default_from, :request_style

    def init
      yield self if block_given?

      if self.request_style == nil
        self.request_style = "async_request"
      end
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

    def defer_success_on_201(http)
      defer(http) { http.response_header.status == 201 }
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


    # When the GET/POST from the MA comes back (in the case of MT messages)
    # Message Gateway will consider success based on the response.
    # This method returns a symbol which points to one of the defer_success_on_*
    # methods above.
    #
    # The default implementation of this method takes http status code 200 to be success.
    # If your mobile aggregator returns a different value (such as the more RESTful 201 - resource created)
    # your sender subclass can override this method
    def defer_callback_method()
      return :defer_success_on_200
    end


    # Retrieve the object you should use to make a request to the Mobile Agreegator
    # (if you are implementing a Sender subclass)
    #
    # Certain situations (testing, initial implementation) are easier implemented
    # by sending the post synchronously, for example, or logging the params to a database
    #
    # To configure this: in your gateway.outbound block in your rackup file, set the request_style attribute
    # to the class_name which you want to use.
    #
    # For example:
    # gateway.outbound(...) do |out|
    #   out.request_style = "sync_request"
    # end
    #
    # Will use MessageGatway::SyncRequest - your requests to the mobile aggregator will
    # block. (Useful for testing/development, an anti-pattern for production)
    #
    # Defaults to returning a MessageGatway::AsyncRequest instance
    def request_object
      MessageGateway.const_get( MessageGateway::Util.make_const(self.request_style) ).new
    end
  end
end
