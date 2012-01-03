require 'logger'
require 'rubygems'
require 'rack'
require 'thin'
require 'thin/async'
require 'eventmachine'
require 'em-jack'
require 'chirpstream'
require 'json'
require 'active_record'
require 'thin/async'
require 'will_paginate'
require 'message_gateway/version'
require 'ext/setup'

class MessageGateway
  autoload :Admin,              'message_gateway/admin'
  autoload :Processor,          'message_gateway/processor'
  autoload :Parser,             'message_gateway/parser'
  autoload :Sender,             'message_gateway/sender'
  autoload :Logging,            'message_gateway/logging'
  autoload :MessageLogger,      'message_gateway/message_logger'
  autoload :Message,            'message_gateway/message'
  autoload :Middleware,         'message_gateway/middleware'
  autoload :SmsMessage,         'message_gateway/sms_message'
  autoload :PhoneNumber,        'message_gateway/phone_number'
  autoload :AsyncDispatcher,    'message_gateway/async_dispatcher'
  autoload :AsyncRequest,       'message_gateway/request_strategies/async_request'
  autoload :SyncRequest,        'message_gateway/request_strategies/sync_request'
  autoload :BeanstalkClient,    'message_gateway/beanstalk_client'
  autoload :SmsSendingEndpoint, 'message_gateway/sms_sending_endpoint'
  autoload :Util,               'message_gateway/util'

  attr_reader :name, :beanstalk_host, :dispatchers, :processors, :started_at, :log
  attr_accessor :logger, :backend_endpoint

  @@default_logger = nil

  def self.default_logger=(logger)
    @@default_logger = logger
  end

  def self.default_logger
    @@default_logger
  end

  def logger=(logger)
    @logger = logger

    if @logger
      @logger.gateway = self if @logger
      ActiveRecord::Base.logger = @log
    end
  end

  # The constructor for the MessageGateway object takes two parameters:
  #  1. The name of the gateway
  #  2. The HTTP endpoint to call *in your app* when a message is received (a mobile originating message)
  #    This endpoint will receive three parameters - from, to, and body. Message Gateway is responsible
  #    for converting the different Mobile Aggregator passing styles into these consistant parameters.
  #
  #    In this way, you could think of Message Gateway as the OmniAuth of Mobile Aggregators
  def initialize(name, backend_endpoint)
    Thin::Logging.silent = true
    @name, @backend_endpoint, @dispatchers, @processors = name, backend_endpoint, {}, {}
    self.logger = @@default_logger
    @started_at = Time.new
    @log = ::Logger.new(File.open('mg.log', File::WRONLY | File::APPEND | File::CREAT))
    puts "Starting message gateway -- connecting to #{backend_endpoint}"
  end


  # Returns the ENDPOINT used to send messages out (mobile terminating). (an SmsSendingEndpoint)
  def sms_sending_endpoint
    @sms_sending_endpoint ||= SmsSendingEndpoint.new(self)
  end

  def beanstalk(host)
    @beanstalk_host = host
  end

	# Sets up a mobile agreegator for incoming messages
	# (Or, in industry speak, "mobile originating" messages)
	#
	# The first param is what type of processing you want (async, or syncronous)
	# The second params is the name of the endpoint
	# 
	# Take the results from this call and call #parser on it,
	# to inform message gateway which mobile agreegator to use for
	# messages coming down this pipe.
  def inbound(type, name, *args)
    raise("inbound #{name} already exists") if @processors.key?(name)
    processor = self.class.const_get(:Processor).const_get(MessageGateway::Util.make_const(type)).new(*args)
    processor.gateway = self
    processor.name = name
    EM.schedule { processor.init }
    @processors[name] = processor
  end

  def tube_for_name(name, type)
    "#{@name}-#{type}-#{name}"
  end


	# MessageGateway comes with its own Admin (Sinatra) app, to allow you to see the messages in the que, or even replay messages
	# This method fires up that application (also depends on your rackup file)
	# 
	# You would use this in your rackup file to connect the sinatra app to a URL path
  def admin(options={})
    Admin.new(self, options)
  end

	# MG has the ability to replay messages, to aid debugging. (This is used by the admin app, for example)
	# replay_wt replays a MOBILE TERMINATING SMS message (a message that we SEND TO a phone)
  def replay_mt(msg)
    if @dispatchers[msg.source]
      @dispatchers[msg.source].inject(msg) 
    end
  end

	# See documentation for replay_mt, except this function replays MOBILE ORIGINATING messages
	# (a message that COMES FROM a phone)
  def replay_mo(msg)
    if @processors[msg.source]
      @processors[msg.source].process(msg)
    end
  end

	# This method sets up new mobile aggregators for OUTBOUND (mobile terminating) messages.
	#
	# You can interface with it one of two ways:
	# 1.) Pass an instance of your MessageGateway::Sender subclass. This instance should respond to #call, as defined in the informal interface
	# 2.) Pass a string of your subclass name. underscores are converted to capital letters
	#   (like Rails finds the constant RequiredTodos from "has_many :required_todos"
	#
	# To see the avaliable classes (ie: mobile agreegators), look at mesasge_gateway/sender/*.rb
	#
	# THIS NEEDS TO BE CALLED FROM YOUR RACKUP FILE!!
  def outbound(o, name, &blk)
    if o.respond_to?(:call)
      puts "scheduling adding an outbound aggregator"
      o.gateway = self
      o.name = name
      o.init(&blk)
      o.start
      EM.schedule { add_outbound(o) }
    else
      outbound(MessageGateway.const_get(:Sender).const_get(MessageGateway::Util.make_const(o)).new, name, &blk)
    end
  end

  def add_outbound(out)
    raise("outbound #{out.name} already exists") if @dispatchers.key?(out.name)
    dispatcher = AsyncDispatcher.new(tube_for_name(out.name, 'outbound'), out)
    dispatcher.gateway = self
    @dispatchers[out.name] = dispatcher
    puts "outbound source #{out.name} configured"
    dispatcher.start
  end
end
