require 'logger'
require 'rack'
require 'thin'
require 'thin/async'
require 'eventmachine'
require 'em-jack'
require 'chirpstream'
require 'json'
require 'activerecord'
require 'thin/async'
require 'will_paginate'
require 'message_gateway/version'

WillPaginate.enable_activerecord

module ActiveRecord
  module ConnectionAdapters
    module QueryCache
      private
      def cache_sql(sql)
        yield
      end
    end
  end
end

class MessageGateway
  autoload :Admin,              'message_gateway/admin'
  autoload :Processor,          'message_gateway/processor'
  autoload :Parser,             'message_gateway/parser'
  autoload :Sender,             'message_gateway/sender'
  autoload :Logging,            'message_gateway/logging'
  autoload :Logger,             'message_gateway/logger'
  autoload :Message,            'message_gateway/message'
  autoload :SmsMessage,         'message_gateway/sms_message'
  autoload :PhoneNumber,        'message_gateway/phone_number'
  autoload :AsyncDispatcher,    'message_gateway/async_dispatcher'
  autoload :BeanstalkClient,    'message_gateway/beanstalk_client'
  autoload :SmsSendingEndpoint, 'message_gateway/sms_sending_endpoint'
  autoload :Util,               'message_gateway/util'

  attr_reader :backend_endpoint, :name, :beanstalk_host, :dispatchers, :processors, :started_at, :log
  attr_accessor :logger

  @@default_logger = nil

  def self.default_logger=(logger)
    @@default_logger = logger
  end

  def self.default_logger
    @@default_logger
  end

  def logger=(logger)
    @logger = logger
    ActiveRecord::Base.logger = @log if logger
  end

  def initialize(name, backend_endpoint)
    Thin::Logging.silent = true
    @name, @backend_endpoint, @dispatchers, @processors = name, backend_endpoint, {}, {}
    self.logger = @@default_logger
    @started_at = Time.new
    @log = ::Logger.new(File.open('mg.log', File::WRONLY | File::APPEND | File::CREAT))
    puts "Starting message gateway -- connecting to #{backend_endpoint}"
  end

  def sms_sending_endpoint
    @sms_sending_endpoint ||= SmsSendingEndpoint.new(self)
  end

  def beanstalk(host)
    @beanstalk_host = host
  end

  def inbound(type, name, *args)
    processor = self.class.const_get(:Processor).const_get(make_const(type)).new(*args)
    processor.gateway = self
    processor.name = name
    EM.schedule { processor.init }
    @processors[name] = processor
  end

  def tube_for_name(name, type)
    "#{@name}-#{type}-#{name}"
  end

  def admin
    Admin.new(self)
  end

  def replay_mt(msg)
    if @dispatchers[msg.source]
      puts "REPLAY_MT #{msg.inspect}"
      @dispatchers[msg.source].inject(msg) 
    end
  end

  def replay_mo(msg)
    if @processors[msg.source]
      @processors[msg.source].process(msg)
      puts "REPLAY_MO #{msg.inspect}"
    end
  end

  def outbound(o, name, &blk)
    if o.respond_to?(:call)
      o.gateway = self
      o.name = name
      o.init(&blk)
      o.start
      EM.schedule { add_outbound(o) }
    else
      outbound(MessageGateway.const_get(:Sender).const_get(make_const(o)).new, name, &blk)
    end
  end

  def add_outbound(out)
    dispatcher = AsyncDispatcher.new(tube_for_name(out.name, 'outbound'), out)
    dispatcher.gateway = self
    @dispatchers[out.name] = dispatcher
    dispatcher.start
  end

  def make_const(name)
    name.to_s.split('_').map{|n| n.capitalize}.join.to_s
  end
end