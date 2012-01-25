require 'active_record'
require 'logger'

class MessageGateway
  class MessageLogger
    autoload :State,        'message_gateway/message_logger/state'
    autoload :Event,        'message_gateway/message_logger/event'

    attr_reader :statuses, :sources
    attr_accessor :gateway

    def initialize(opts)
      ActiveRecord::Base.logger = nil
      ActiveRecord::Base.establish_connection(opts)
      ActiveRecord::Base.connection.__send__(:instance_variable_set, :@query_cache_enabled, false)
      reset! rescue nil
      init_filter_criteria
      puts "Starting logger"
    end

    def init_filter_criteria
      @sources = Event.find_by_sql("select distinct source from states").map(&:source)
      @statuses = Event.find_by_sql("select distinct status from states").map(&:status)
    end

    def soft_reset!
      ActiveRecord::Base.connection.execute "truncate events"
      ActiveRecord::Base.connection.execute "truncate states"
    end

    def reset!(force = false)
      ActiveRecord::Schema.define :version => 0 do
        create_table :events, :force => force do |t|
          t.integer :state_id, :null => false
          t.text :error, :null => true
          t.string :status, :limit => 30, :null => false
          t.datetime :created_at
        end

        add_index "events", "state_id"

        create_table :states, :force => force do |t|
          t.string :status, :limit => 30, :null => false
          t.string :from, :null => false
          t.string :to, :null => false
          t.string :body, :null => false
          t.string :carrier_id, :null => true
          t.string :source, :null => false
          t.string :extra
          t.integer :reply_to_id, :null => true
          t.timestamps :create_at
        end

        add_index "states", "status"
        add_index "states", "source"
        add_index "states", "to"
      end
    end

    def record_status(message, status, err = nil)
      @statuses << status.to_s unless @statuses.include?(status.to_s)
      @sources << message.source unless @sources.include?(message.source)
      state = State.record_status(message, status.to_s, err)
    rescue
     msg = "Error recording status: #{$!.message}\n#{$!.backtrace.join("\n  ")}"
      MessageGateway::SysLogger.error msg
    ensure
      state
    end
  end
end
