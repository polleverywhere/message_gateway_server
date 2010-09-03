require 'spec_helper'
require "em-spec/rspec"
require 'dirge'

describe MessageGateway::Processor::Sync do
  before(:each) do
    MessageGateway.default_logger.soft_reset!
    restart_beanstalkd
  end

  after(:each) do
    stop_beanstalkd
  end

  it "should receive and dispatch a message right away" do
    EM.run do
      gateway = start_processor { |gateway|
        gateway.inbound(:sync, 'test').parser(create_parser{|env| MessageGateway::Message.new('from', 'to', 'body', 'source')})
      }
      start_backend { |env| 
        req = Rack::Request.new(env)
        req['from'].should == 'from'
        req['to'].should == 'to'
        req['body'].should == 'body'
        req['source'].should == 'source'
        [200, {}, ['Thank you for your vote(s).']]
      }
      http = test_processor
      http.callback {
        http.response.should == "Thank you for your vote(s)."
        gateway.processors['test'].mo_success_buckets.should == [1]
        states = MessageGateway::MessageLogger::State.find(:all, :order => 'id asc')
        states.size.should == 2
        states.first.body.should == 'body'
        states.first.status.should == 'mo_success'
        states.second.body.should == 'Thank you for your vote(s).'
        states.second.status.should == 'mt_success'
        EM.stop
      }
    end
  end

  it "should strip whitespace from responses" do
    EM.run do
      gateway = start_processor { |gateway|
        gateway.inbound(:sync, 'test').parser(create_parser{|env| MessageGateway::Message.new('from', 'to', 'body', 'source')})
      }
      start_backend { |env| 
        req = Rack::Request.new(env)
        req['from'].should == 'from'
        req['to'].should == 'to'
        req['body'].should == 'body'
        req['source'].should == 'source'
        [200, {}, ["Thank you for your vote(s).\n\n\n"]]
      }
      http = test_processor
      http.callback {
        http.response.should == "Thank you for your vote(s)."
        gateway.processors['test'].mo_success_buckets.should == [1]
        EM.stop
      }
    end
  end

  it "should log correctly if the backend if down" do
    EM.run do
      gateway = start_processor { |gateway|
        gateway.inbound(:sync, 'test').parser(create_parser{|env| MessageGateway::Message.new('from', 'to', 'body', 'test')})
      }
      start_backend { |env| 
        [500, {}, ["Thank you for your vote(s).\n\n\n"]]
      }
      http = test_processor
      http.callback {
        gateway.processors['test'].mo_success_buckets.should == [0]
        state = MessageGateway::MessageLogger::State.first
        state.status.should == 'mo_permanent_failure'
        state.body.should == 'body'
        MessageGateway::MessageLogger::Event.find(:all, :order => 'id asc').map(&:status).should == ["mo_start", "mo_failure", "mo_failure", "mo_failure", "mo_failure", "mo_failure", "mo_permanent_failure"]
        EM.stop
      }
    end
  end

  it "should replay the same message if the backend was temporarily down" do
    EM.run do
      gateway = start_processor { |gateway|
        gateway.inbound(:sync, 'test').parser(create_parser{|env| MessageGateway::Message.new('from', 'to', 'body', 'test')})
      }
      gateway.beanstalk('127.0.0.1')
      gateway.outbound(create_sender{|message|
        message.from.should == 'to'
        message.to.should == 'from'
        message.body.should == 'Thank you for your vote(s).'
        message.source.should == 'test'
        defer = EM::DefaultDeferrable.new
        defer.succeed
        defer
      }, 'test')
      start_backend { |env| 
        [500, {}, ["Thank you for your vote(s).\n\n\n"]]
      }
      start_backend(10101) { |env| 
        [200, {}, ["Thank you for your vote(s).\n\n\n"]]
      }
      http = test_processor
      http.callback {
        gateway.processors['test'].mo_success_buckets.should == [0]
        state = MessageGateway::MessageLogger::State.first
        state.status.should == 'mo_permanent_failure'
        state.body.should == 'body'
        MessageGateway::MessageLogger::Event.find(:all, :order => 'id asc').map(&:status).should == ["mo_start", "mo_failure", "mo_failure", "mo_failure", "mo_failure", "mo_failure", "mo_permanent_failure"]
        gateway.backend_endpoint = "http://127.0.0.1:10101/sms"
        gateway.replay_mo(state.to_message)
        EM.add_timer(0.3) do
          MessageGateway::MessageLogger::Event.find(:all, :order => 'id asc').map(&:status).should == ["mo_start", "mo_failure", "mo_failure", "mo_failure", "mo_failure", "mo_failure", "mo_permanent_failure", 'mo_start', 'mo_success', 'mt_start', 'mt_success']
          gateway.dispatchers['test'].success_count.should == 1
          gateway.processors['test'].mo_success_buckets.should == [1]
          states = MessageGateway::MessageLogger::State.find(:all, :order => 'id asc')
          states.size.should == 2
          states.first.body.should == 'body'
          states.first.status.should == 'mo_success'
          states.second.body.should == 'Thank you for your vote(s).'
          states.second.status.should == 'mt_success'
          EM.stop
        end
      }
    end
  end

  it "should receive and dispatch a message right away" do
    EM.run do
      gateway = start_processor { |gateway|
        gateway.inbound(:sync, 'test').parser(create_parser{|env| MessageGateway::Message.new('from', 'to', 'body', 'source')})
      }
      start_backend { |env| 
        req = Rack::Request.new(env)
        req['from'].should == 'from'
        req['to'].should == 'to'
        req['body'].should == 'body'
        req['source'].should == 'source'
        [200, {}, ['']]
      }
      http = test_processor
      http.callback {
        http.response.should == ""
        gateway.processors['test'].mo_success_buckets.should == [1]
        states = MessageGateway::MessageLogger::State.find(:all, :order => 'id asc')
        states.size.should == 1
        states.first.body.should == 'body'
        states.first.status.should == 'mo_success'
        EM.stop
      }
    end
  end
end