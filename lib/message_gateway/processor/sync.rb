require 'thin/async'

class MessageGateway
  class Processor
    class Sync < Processor
      include Util::TrafficLights

      attr_reader :waiting_jobs

      def init
        super
        @waiting_jobs = 0
      end

      def call(env)
        response = Thin::AsyncResponse.new(env)
        response.status = 200
        message = @parser_instance.call(env)
        process(message, response)
        response.finish
      end
      
      def process(message, response = nil, count = 0)
        if count >= MAX_ERRORS
          log_mo_permanent_failure(message)
          response.done if response
        else
          log_mo_start(message) if count == 0
          @waiting_jobs += 1
          http = send_message(message)
          http.callback do
            @waiting_jobs -= 1
            if http.response_header.status == 200
              log_mo_success(message)
              report_success
              response_text = http.response.strip
              if !response_text.empty?
                reply_message = message.reply(response_text)
                log_mt_start(reply_message)
                log_mt_success(reply_message)
                response << response_text
              end
              response.done
            else
              log_mo_failure(message, "#{http.response_header.status}\n#{http.response}")
              process(message, response, count + 1)
            end
          end
          http.errback do |err|
            @waiting_jobs -= 1
            log_mo_failure(message, err.to_s)
            process(message, response, count + 1)
          end
        end
      end
    end
  end
end