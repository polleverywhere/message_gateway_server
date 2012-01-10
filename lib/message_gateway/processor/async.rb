class MessageGateway
  class Processor
    class Async < Processor

      include BeanstalkClient
      include Util::TrafficLights

      attr_reader :waiting_jobs

      def init
        super
        @beanstalk_producer_client ||= beanstalk_connection
            # holds messages that need to be sent to the "message received application callback"
            # the "in" end of the tube that holds messages awaiting delivery to our main application service

        @beanstalk_consumer_client ||= beanstalk_connection
            # retrieves messages that need to be sent to the "message received application callback"
            # and sends them to said endpoint
            # the "out" end of the tub that holds messages awaiting delivery.

        if gateway.dispatchers[name].nil?
          raise "You need to define an outbound route for every inbound route you name. Need outbound route for #{name}"
        end

        @beanstalk_dispatcher_producer_client ||= beanstalk_connection(gateway.dispatchers[name].tube_name)
            # stores messages that need to be sent back to the mobile aggregator (OK messages and the like)
            # from the README: "In the asynchronous model, a separate sending processor has to be setup, separate from the endpoint for incoming messages"

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

      # Gets called when Rack/HttpRouter determines that a request is for us.
      # In this class's implementation, we shove the message on a beanstalk and return immediately
      # (Async#run processes these)
      def call(env)
        if message = @parser_instance.call(env)  # @parser_instance is the parser we defined in our Rackup file. (So, Twilio's parser, or something)

          # message is now the processed object - all the parameters that the MA has
          # passed us are now normalized into our structure

          response = Thin::AsyncResponse.new(env)
          # now, shove that normalized message into the outbound message queue and
          # send a message back to the MA. This lets us get BACK TO WORK (responding to messages)

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

      # Called via EventMachine. An infinite loop of our own design
      # (See init, log_mo_success, log_mo_permanent_failure)
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
            http = send_message(message) # to message received application callback
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
