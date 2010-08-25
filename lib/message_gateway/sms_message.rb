class MessageGateway
  class SmsMessage < Message
    attr_accessor :carrier_id
    def to_hash
      h = super
      h["carrier_id"] = carrier_id
      h
    end
    
    def self.build_from_hash(hash)
      new_message = super(hash)
      new_message.carrier_id = hash['carrier_id']
      new_message
    end
    
    def extra
      {'carrier_id' => carrier_id}
    end
    
    def carrier
      MessageGateway::Util::Carrier::CarrierInfo.lookup(carrier_id)
    end
  end
end