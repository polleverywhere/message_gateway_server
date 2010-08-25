class MessageGateway
  class Logger
    class Event < ActiveRecord::Base
      belongs_to :state, :class_name => 'MessageGateway::Logger::State'
    end
  end
end
      