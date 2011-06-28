class MessageGateway

  # Processor is the subclass for Async and Sync mobile originating messages (aka: message a user
  # is sending to us).
  #
  # MessageGateway comes with two processors: Asynchronous and Synchronous.
  # These subclasses must respond to the following methods:
  #   * init
  #   * call(env)
  #   * process(message, response)
  #
  # Processor instances are - like SmsSendingEndpoints - simple functors / function objects called
  # by Rack/HttpRouter when a mobile agreegator is relaying a message to us
  class Processor
    include Logging
    
    autoload :Sync,    'message_gateway/processor/sync'
    autoload :Async,   'message_gateway/processor/async'
    
    MAX_ERRORS = 5
    MAX_BUCKETS = 300

    attr_accessor :parser_instance, :name, :mo_success_buckets
    
    def init
      @mo_success_buckets = [0]
      EM.add_periodic_timer(5) do
        @mo_success_buckets << 0
        @mo_success_buckets.shift if @mo_success_buckets.size > MAX_BUCKETS
      end
      banner = "Starting processor #{name} with #{self.class}"
      banner << " (parser -- #{@parser_instance.class})" if @parser_instance
      puts banner
    end
    
    def report_success
      @mo_success_buckets[-1] += 1
    end

    def message(from, to, body, cls = Message)
      cls.new(from, to, body, name, nil)
    end

    # set up the Parser object for this object. Each mobile agreegator has a Parser object, which extracts
    # the custom parameters from the mobile agreegator, and transforms it into a simple and consistant hash
    def parser(p, *args, &blk)
      if p.respond_to?(:call)
        @parser_instance = p
        @parser_instance.processor = self
      else
        parser(MessageGateway.const_get(:Parser).const_get(gateway.make_const(p)).new(*args, &blk))
      end
      self
    end

    # Send translated message to the "message recieved application logic callback" endpoint
    def send_message(message, endpoint = gateway.backend_endpoint, &blk)
      http = EventMachine::HttpRequest.new(endpoint).post :body => message.to_hash, :timeout => 10
      http.callback(&blk) if blk
      http
    end
  end
end