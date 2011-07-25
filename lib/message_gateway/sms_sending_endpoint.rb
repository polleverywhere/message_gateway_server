class MessageGateway

  # An interface to send a SMS message out to the mobile agreegator. Follows a C++ functor (or: functional object)
  # style pattern... later called by Rack/HttpRouter.
  class SmsSendingEndpoint
    
    attr_accessor :default_source
    
    include PhoneNumber

    INTRA_MESSAGE_DELAY = 30
    
    def initialize(gateway)
      @gateway = gateway
    end

    # When called (by Rack/HTTPRouter sending a request its way - see the gem README) it will send
    # the message to a mobile agreegator for transmitting.
    #
    # PARAMS you should pass to this function: to, body, source.
    #   - TO: the phone number to send the message to
    #   - BODY: the message
    #   - SOURCE: the message SENDER subclass with which to send the message. Must correspond with one
    #             of the senders associated with the gateway
    #             [set up in the MessageGateway object by using MessageGateway#outbound or MessageGateway#add_outbound)
    #           If not provided in the rack environment, will use the default sender for this endpoint (again, from the rakup file)
    #
    # SmsSendingEndpoint is an asyncronous model: it puts messages onto a Beanstalk queue (using EventMachine)
    # for later processing
    def call(env)
      req = Rack::Request.new(env)
      
      req['source'] ||= @default_source

      unless source = @gateway.dispatchers[req['source']]
        return Rack::Response.new(["MEASSAGE GATEWAY: The source '#{req['source']}' could not be recognized. Source must be one of the following:\n#{@gateway.dispatchers.keys.join("\n")}"], 400).finish
      end

      req['from'] ||= source.out.default_from

      # parameter checking
      %w(source body to).each do |p|
        if !req.params.key?(p)
          return Rack::Response.new(["MEASSAGE GATEWAY: The parameter '#{p}' must be supplied."], 400).finish
        end
      end

      unless req['body'].empty?
        message_delay = begin 
          req['intra_message_delay'] ? Integer(req['intra_message_delay']) : INTRA_MESSAGE_DELAY
        rescue ArgumentError
          return Rack::Response.new(["MEASSAGE GATEWAY: intra_message_delay must be an int."], 400).finish
        end

        begin
          data = {'from' => sanitize_phone_number(req['from']), 'to' => sanitize_phone_number(req['to']), 'source' => req['source']}
          data['carrier_id'] = req['carrier_id'] if req['carrier_id']
          if data['from'].empty?
            Rack::Response.new(["MEASSAGE GATEWAY: The parameter 'from' must be supplied."], 400).finish
          else
            bodies = begin
              Array(JSON.parse(req['body']))
            rescue JSON::ParserError
              [req['body']]
            end
          
            bodies.each_with_index do |body, index|
              source.inject_with_delay(
                Message.from_hash(data.merge('body' => body)), index * message_delay)
            end

            Rack::Response.new(['OK'], 200).finish
          end
        rescue Message::BadParameter => e
          Rack::Response.new([e.message], 400).finish
        end
      end
    rescue
      @gateway.log.error "#{$!.message}\n#{$!.backtrace.join("\n  ")}"
      Rack::Response.new(['MEASSAGE GATEWAY: There was a problem'], 500).finish
    end
  end
end