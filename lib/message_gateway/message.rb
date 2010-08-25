class MessageGateway
  class Message < Struct.new(:from, :to, :body, :source, :in_reply_to)
    BadParameter = Class.new(RuntimeError)

    attr_accessor :id

    def to_hash
      Hash[members.zip(values)]
    end
    
    def reply(body)
      reply_msg = clone
      reply_msg.id = nil
      reply_msg.in_reply_to = id
      reply_msg.to, reply_msg.from, reply_msg.body = from, to, body
      reply_msg
    end
    
    def extra
      nil
    end
    
    def self.from_hash(hash)
      (hash['carrier_id'] ? SmsMessage : Message).build_from_hash(hash)
    end
    
    def self.build_from_hash(hash)
      raise(BadParameter.new("from cannot be blank"))   if hash['from'].nil? || hash['from'].blank?
      raise(BadParameter.new("body cannot be blank"))   if hash['body'].nil? || hash['body'].blank?
      raise(BadParameter.new("source cannot be blank")) if hash['source'].nil? || hash['source'].blank?
      new(hash['from'], hash['to'], hash['body'], hash['source'], hash['in_reply_to'])
    end
  end
end