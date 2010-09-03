class MessageGateway
  class MessageLogger
    class Event < ActiveRecord::Base
      belongs_to :state, :class_name => 'MessageGateway::MessageLogger::State'
    end
  end
end
      