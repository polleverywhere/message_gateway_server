require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::Celltrust do
  before(:each) do
    EM::MockHttpRequest.activate!
    EM::MockHttpRequest.pass_through_requests = false
    EM::MockHttpRequest.register_file("https://www.primemessage.net:443/TxTNotify/TxTNotify", :get, ~'../processor/fixtures/twitter/send.txt')
    @sender = MessageGateway::Sender::Celltrust.new
    @sender.customer_nickname = 'nickname'
    @sender.login = 'login'
    @sender.password = 'password'
  end

  after(:each) do
    EM::MockHttpRequest.deactivate!
  end

  it "should send a message" do
    EM.run do
      defer = @sender.call(MessageGateway::Message.new('from', 'to', "body", 'celltrust'))
      defer.callback {
        1.should == 1
        EM.stop
      }
      defer.errback { |err|
        fail
        EM.stop
      }
    end
  end
end