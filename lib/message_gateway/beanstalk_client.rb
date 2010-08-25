class MessageGateway
  include Util::TrafficLights

  module BeanstalkClient
    def beanstalk_connection(tube = tube_name)
      EMJack::Connection.new(:host => gateway.beanstalk_host, :tube => tube)
    end
  end
end