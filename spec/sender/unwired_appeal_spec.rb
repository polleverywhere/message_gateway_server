require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::UnwiredAppeal do
  before(:each) do
    EM::MockHttpRequest.activate!
    EM::MockHttpRequest.pass_through_requests = false
    @sender = MessageGateway::Sender::UnwiredAppeal.new
    @sender.event_id = 'event_id'
    @sender.password = 'password'
  end

  after(:each) do
    EM::MockHttpRequest.deactivate!
  end

  it "should send a message" do
    EM.run do
      EM::MockHttpRequest.register_file("http://appsrv.unwiredappeal.com:80/uwa_umap/eventhandler.srv?number=11234567890&msg=body&evid=event_id&carrier=12&pw=password", :get, ~'../processor/fixtures/twitter/send.txt')
      message = MessageGateway::SmsMessage.new('41411', '1234567890', "body", 'united_appeal')
      message.carrier_id = 'virgin_mobile'
      defer = @sender.call(message)
      defer.callback {
        1.should == 1
        EM.stop
      }
      defer.errback { |err|
        p err
        fail
        EM.stop
      }
    end
  end
end