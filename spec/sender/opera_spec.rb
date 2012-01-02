require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::Opera do
  before(:each) do
    EM::MockHttpRequest.activate!
    EM::MockHttpRequest.pass_through_requests = false
    @sender = MessageGateway::Sender::Opera.new
    @sender.init
    @sender.username = 'username'
    @sender.password = 'password'
    @sender.campaign_id = 'campaign_id'
    @sender.endpoint = 'http://thiismyendpoint:8080/'
  end

  after(:each) do
    EM::MockHttpRequest.deactivate!
  end

  it "should send a message" do
    EM.run do
      EM::MockHttpRequest.register_file("http://thiismyendpoint:8080/", :post, ~'../processor/fixtures/twitter/send.txt')
      message = MessageGateway::SmsMessage.new('from', 'to', "body", 'mblox')
      message.carrier_id = :ireland_3
      defer = @sender.call(message)
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
