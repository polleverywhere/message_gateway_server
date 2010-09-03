require 'spec_helper'

describe MessageGateway::SmsSendingEndpoint do
  before(:each) do 
    MessageGateway.default_logger.soft_reset!
    restart_beanstalkd
  end

  after(:each) do
    stop_beanstalkd
  end
  
  it "should receive a message" do
    EM.run do
      EM.next_tick do
        @gateway = start_gateway
        @gateway.beanstalk('127.0.0.1')
        @gateway.outbound(create_sender{|message|
          message.from.should == '41411'
          message.to.should == '123456'
          message.body.should == 'Thank you for your vote(s).'
          message.source.should == 'test'
          defer = EM::DefaultDeferrable.new
          defer.succeed
          defer
        }, 'test')
        @gateway.dispatchers['test'].success_count.should == 0
        response = @gateway.sms_sending_endpoint.call(Rack::MockRequest.env_for("/?#{Rack::Utils.build_query('to' => '123456', 'from' => '41411', 'body' => 'Thank you for your vote(s).', 'source' => 'test')}"))
        response.first.should == 200
        EM.add_timer(0.2) {
          @gateway.dispatchers['test'].success_count.should == 1
          states = MessageGateway::MessageLogger::State.find(:all, :order => 'id asc')
          states.size.should == 1
          states.first.body.should == 'Thank you for your vote(s).'
          states.first.status.should == 'mt_success'
          EM.stop
        }
      end
    end
  end

  it "should receive multiple messages" do
    EM.run do
      EM.next_tick do
        @gateway = start_gateway
        @gateway.beanstalk('127.0.0.1')
        @gateway.outbound(create_sender{|message|
          message.from.should == '41411'
          message.to.should == '123456'
          message.body.should == 'Thank you for your vote(s).'
          message.source.should == 'test'
          defer = EM::DefaultDeferrable.new
          defer.succeed
          defer
        }, 'test')
        @gateway.dispatchers['test'].success_count.should == 0
        response = @gateway.sms_sending_endpoint.call(Rack::MockRequest.env_for("/?#{Rack::Utils.build_query('to' => '123456', 'from' => '41411', 'body' => ['Thank you for your vote(s).', 'Thank you for your vote(s).', 'Thank you for your vote(s).'].to_json, 'source' => 'test', 'intra_message_delay' => '1')}"))
        response.first.should == 200
        EM.add_timer(3.2) {
          @gateway.dispatchers['test'].success_count.should == 3
          states = MessageGateway::MessageLogger::State.find(:all, :order => 'id asc')
          states.size.should == 3
          states.map(&:body).uniq.size.should == 1
          states.map(&:body).uniq.first.should == 'Thank you for your vote(s).'
          states.map(&:status).uniq.size.should == 1
          states.map(&:status).uniq.first.should == 'mt_success'
          EM.stop
        }
      end
    end
  end

end
