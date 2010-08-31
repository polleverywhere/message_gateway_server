class MessageGateway
  class SmsSendingEndpoint
    
    attr_accessor :default_source
    
    include PhoneNumber

    INTRA_MESSAGE_DELAY = 30
    
    def initialize(gateway)
      @gateway = gateway
    end

    def call(env)
      req = Rack::Request.new(env)
      
      req['source'] ||= @default_source

      unless source = @gateway.dispatchers[req['source']]
        return Rack::Response.new(["The source '#{req['source']}' could not be recognized. Sound must be one of the following:\n#{@gateway.dispatchers.keys.join("\n")}"], 400).finish
      end

      req['from'] ||= source.out.default_from

      # parameter checking
      %w(source body to).each do |p|
        if !req.params.key?(p)
          return Rack::Response.new(["The parameter '#{p}' must be supplied."], 400).finish
        end
      end

      unless req['body'].empty?
        message_delay = begin 
          req['intra_message_delay'] ? Integer(req['intra_message_delay']) : INTRA_MESSAGE_DELAY
        rescue ArgumentError
          return Rack::Response.new(["intra_message_delay must be an int."], 400).finish
        end

        begin
          data = {'from' => sanitize_phone_number(req['from']), 'to' => sanitize_phone_number(req['to']), 'source' => req['source']}
          data['carrier_id'] = req['carrier_id'] if req['carrier_id']
          if data['from'].empty?
            Rack::Response.new(["The parameter 'from' must be supplied."], 400).finish
          else
            bodies = begin
              Array(JSON.parse(req['body']))
            rescue JSON::ParserError
              [req['body']]
            end
          
            bodies.each_with_index { |body, index| source.inject_with_delay(Message.from_hash(data.merge('body' => body)), index * message_delay) }
            Rack::Response.new(['OK'], 200).finish
          end
        rescue Message::BadParameter => e
          Rack::Response.new([e.message], 400).finish
        end
      end
    rescue
      @gateway.log.error "#{$!.message}\n#{$!.backtrace.join("\n  ")}"
      Rack::Response.new(['There was a problem'], 500).finish
    end
  end
end