class MessageGateway
  class Processor
    class Async < Processor

      include BeanstalkClient
      include Util::TrafficLights
      
      attr_reader :waiting_jobs
      
      def init
        super
        @beanstalk_producer_client ||= beanstalk_connection
        @beanstalk_consumer_client ||= beanstalk_connection
        @beanstalk_dispatcher_producer_client ||= beanstalk_connection(gateway.dispatchers[name].tube_name)
        EM.next_tick{run}
        @beanstalk_counting_client ||= beanstalk_connection
        @waiting_jobs = 0
        EM.add_periodic_timer(1) do
          @beanstalk_counting_client.stats(:tube, tube_name) do |stats|
            @waiting_jobs = stats['current-jobs-ready']
          end
        end
      end
      
      def beanstalk_dispatcher_producer_client
        @beanstalk_dispatcher_producer_client ||= beanstalk_connection(gateway.dispatchers[name].tube_name)
      end
      
      def tube_name
        gateway.tube_for_name(name, 'incoming')
      end
      
      def call(env)
        if message = @parser_instance.call(env)
          response = Thin::AsyncResponse.new(env)
          @beanstalk_producer_client.put(message.to_hash.to_json) {
            response.status = 200
            response << 'OK'
            response.done
          }.errback {
            response.status = 500
            response << 'ERROR'
            response.done
          }
          response.finish
        else
          [400, {}, []]
        end
      end

      def run
        @beanstalk_consumer_client.reserve do |job|
          @job = job
          process(Message.from_hash(JSON.parse(job.body)), 0, job)
        end
      end

      def log_mo_permanent_failure(message, err = nil)
        super
        EM.next_tick{run}
      end

      def log_mo_success(message)
        super
        EM.next_tick{run}
      end

      def process(message, count = 0, job = nil)
        if count >= MAX_ERRORS
          if job
            job.delete {log_mo_permanent_failure(message)}
          else
            log_mo_permanent_failure(message)
          end
        else
          log_mo_start(message) if count == 0
          EM.next_tick do
            http = send_message(message)
            http.callback do
              if http.response_header.status == 200
                reply_body = http.response.strip
                if reply_body.empty?
                  if job
                    job.delete {log_mo_success(message)}
                  else
                    log_mo_success(message)
                  end
                  report_success
                else
                  @beanstalk_dispatcher_producer_client.put({'message' => message.reply(reply_body).to_hash}.to_json) {
                    if job
                      job.delete {log_mo_success(message)}
                    else
                      log_mo_success(message)
                    end
                    report_success
                  }
                end
              else
                log_mo_failure(message, "#{http.response_header.status}\n#{http.response}")
                process(message, count + 1, job)
              end
            end
            http.errback do |err|
              log_mo_failure(message, err.to_s)
              process(message, count + 1, job)
            end
          end
        end
      end
      
    end
  end
end