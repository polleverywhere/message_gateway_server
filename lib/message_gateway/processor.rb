class MessageGateway
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
    
    def parser(p, *args, &blk)
      if p.respond_to?(:call)
        @parser_instance = p
        @parser_instance.processor = self
      else
        parser(MessageGateway.const_get(:Parser).const_get(gateway.make_const(p)).new(*args, &blk))
      end
      self
    end
    
    def send_message(message, endpoint = gateway.backend_endpoint, &blk)
      http = EventMachine::HttpRequest.new(endpoint).post :body => message.to_hash, :timeout => 10
      http.callback(&blk) if blk
      http
    end
  end
end