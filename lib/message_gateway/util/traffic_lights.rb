class MessageGateway
  module Util
    module TrafficLights
      def traffic_light_status
        case waiting_jobs
        when 0...10
          'green'
        when 10...50
          'yellow'
        else
          'red'
        end
      end
    end
  end
end