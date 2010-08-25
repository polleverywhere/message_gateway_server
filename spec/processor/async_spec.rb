require 'spec_helper'
require "em-spec/rspec"
require 'dirge'

describe MessageGateway::Processor::Async do
  before(:each) do
    MessageGateway.default_logger.soft_reset!
    restart_beanstalkd
  end

  after(:each) do
    stop_beanstalkd
  end

  it "should receive and dispatch a message asynchronously" do
    EM.run do
      gateway = start_processor { |gateway|
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
        gateway.inbound(:async, 'test').parser(create_parser{|env| MessageGateway::Message.new('from', 'to', 'body', 'test')})
      }
      start_backend { |env| 
        req = Rack::Request.new(env)
        req['from'].should == 'from'
        req['to'].should == 'to'
        req['body'].should == 'body'
        req['source'].should == 'test'
        [200, {}, ['Thank you for your vote(s).']]
      }
      http = test_processor
      http.callback {
        http.response.should == "OK"
      }
      gateway.dispatchers['test'].success_count.should == 0
      EM.add_timer(0.5) {
        gateway.dispatchers['test'].success_count.should == 1
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

  it "should receive and dispatch a message but put into permanent failure if the backend is down" do
    EM.run do
      gateway = start_processor { |gateway|
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
        gateway.inbound(:async, 'test').parser(create_parser{|env| MessageGateway::Message.new('from', 'to', 'body', 'test')})
      }
      start_backend { |env| 
        [500, {}, ['Thank you for your vote(s).']]
      }
      http = test_processor
      http.callback {
        http.response.should == "OK"
      }
      EM.add_timer(0.5) {
        gateway.processors['test'].mo_success_buckets.should == [0]
        state = MessageGateway::Logger::State.first
        state.status.should == 'mo_permanent_failure'
        state.body.should == 'body'
        EM.stop
      }
    end
  end

end