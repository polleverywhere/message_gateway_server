require 'spec_helper'
require "em-spec/rspec"
require 'dirge'

describe MessageGateway::Processor::Sync do
  before(:each) do
    MessageGateway.default_logger.soft_reset!
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
        states = MessageGateway::Logger::State.find(:all, :order => 'id asc')
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
        gateway.inbound(:sync, 'test').parser(create_parser{|env| MessageGateway::Message.new('from', 'to', 'body', 'source')})
      }
      start_backend { |env| 
        [500, {}, ["Thank you for your vote(s).\n\n\n"]]
      }
      http = test_processor
      http.callback {
        gateway.processors['test'].mo_success_buckets.should == [0]
        state = MessageGateway::Logger::State.first
        state.status.should == 'mo_permanent_failure'
        state.body.should == 'body'
        MessageGateway::Logger::Event.find(:all, :order => 'id asc').map(&:status).should == ["mo_start", "mo_failure", "mo_failure", "mo_failure", "mo_failure", "mo_failure", "mo_permanent_failure"]
        EM.stop
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
        states = MessageGateway::Logger::State.find(:all, :order => 'id asc')
        states.size.should == 1
        states.first.body.should == 'body'
        states.first.status.should == 'mo_success'
        EM.stop
      }
    end
  end
end