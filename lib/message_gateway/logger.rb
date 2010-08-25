require 'activerecord'
require 'logger'

class MessageGateway
  class Logger
    autoload :State,        'message_gateway/logger/state'
    autoload :Event,        'message_gateway/logger/event'

    attr_reader :statuses, :sources

    def initialize(opts)
      ActiveRecord::Base.logger = nil
      ActiveRecord::Base.establish_connection(opts)
      ActiveRecord::Base.connection.send(:instance_variable_set, :@query_cache_enabled, false)
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
      ActiveRecord::Base.connection.execute "truncate error_messages"
    end

    def reset!(force = false)
      ActiveRecord::Schema.define :version => 0 do
        create_table :events, :force => force do |t|
          t.integer :state_id, :null => false
          t.text :error, :null => true
          t.string :status, :limit => 30, :null => false
          t.datetime :created_at
          t.add_index :hash
        end

        create_table :states, :force => force do |t|
          t.string :status, :limit => 30, :null => false
          t.string :from, :null => false
          t.string :to, :null => false
          t.string :body, :null => false
          t.string :source, :null => false
          t.string :extra
          t.integer :reply_to_id, :null => true
          t.timestamps :create_at
          t.add_index :status
          t.add_index :source
          t.add_index :to
        end
      end
    end
    
    def record_status(message, status, err = nil)
      @statuses << status.to_s unless @statuses.include?(status.to_s)
      @sources << message.source unless @sources.include?(message.source)
      state = State.record_status(message, status.to_s, err)
      state
    rescue
      puts "#{$!.message}\n#{$!.backtrace.join("\n  ")}"
    end
  end
end