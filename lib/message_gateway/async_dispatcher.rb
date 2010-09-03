class MessageGateway
  class AsyncDispatcher
    include Logging
    include BeanstalkClient
    include Util::TrafficLights
    
    attr_reader :waiting_jobs, :out

    MAX_BUCKETS = 300
    MAX_FAILURES = 5

    attr_accessor :success_count, :failure_count, :mt_success_buckets
    
    def initialize(tube, out)
      @tube, @out, @success_count, @failure_count, @mt_success_buckets = tube, out, 0, 0, [0]
    end
    
    def start
      raise "You need a beanstalk host" unless gateway.beanstalk_host
      EM.add_periodic_timer(5) do
        @mt_success_buckets << 0
        @mt_success_buckets.shift if @mt_success_buckets.size > MAX_BUCKETS
      end
      @beanstalk_connection = beanstalk_connection
      @beanstalk_counting_client = beanstalk_connection
      EM.add_periodic_timer(1) do
        @beanstalk_counting_client.stats(:tube, tube_name) do |stats|
          @waiting_jobs = stats['current-jobs-ready']
        end
      end
      process
    end
    
    def tube_name
      @tube
    end
    
    def beanstalk_connection
      EMJack::Connection.new(:host => gateway.beanstalk_host, :tube => tube_name)
    end
    
    def inject(message)
      EMJack::Connection.new(:host => gateway.beanstalk_host, :tube => tube_name).put({'message' => message.to_hash}.to_json)
    end
    
    def inject_with_delay(message, delay)
      EMJack::Connection.new(:host => gateway.beanstalk_host, :tube => tube_name).put({'message' => message.to_hash}.to_json, :delay => delay)
    end
    
    def process
      @beanstalk_connection.reserve do |job|
        parsed_job = JSON.parse(job.body)
        parsed_job['attempts'] ||= 0
        begin
          message = Message.from_hash(parsed_job['message'])
          log_mt_start(message) if parsed_job['attempts'] == 0
          begin
            send = @out.call(message)
            send.callback do
              job.delete {
                increment_success
                log_mt_success(message)
                process
              }
            end
            send.errback { |err|
              gateway.log.error err
              retry_job(job, parsed_job, message)
            }
          rescue
            gateway.log.error "#{$!.message}\n#{$!.backtrace.join("\n")}"
            retry_job(job, parsed_job, message)
          end
        rescue Message::BadParameter
          gateway.log.error "Unable to construct message from #{parsed_job['message'].inspect}"
          job.delete
          process
        end
      end
    end
    
    def retry_job(job, parsed_job, message)
      increment_failure
      parsed_job['attempts'] += 1
      if parsed_job['attempts'] >= MAX_FAILURES
        log_mt_permanent_failure(message)
        job.delete {
          process
        }
      else
        job.delete {
          @beanstalk_connection.put(parsed_job.to_json, :delay => 5 + (2 ** parsed_job['attempts'])) {
            log_mt_failure(message)
            process
          }
        }
      end
    end

    def increment_failure
      @failure_count += 1
    end

    def increment_success
      @success_count += 1
      @mt_success_buckets[-1] += 1
    end
  end
end