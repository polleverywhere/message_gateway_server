class MessageGateway
  module Util
    autoload :Carrier,       'message_gateway/util/carrier'
    autoload :TrafficLights, 'message_gateway/util/traffic_lights'

    def self.make_const(name)
      name.to_s.split('_').map{|n| n.capitalize}.join.to_s
    end
  end
end