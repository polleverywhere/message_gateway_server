require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::MxTelecom do
  before(:each) do
    EM::MockHttpRequest.activate!
    EM::MockHttpRequest.pass_through_requests = false
    @sender = MessageGateway::Sender::MxTelecom.new
    @sender.shortcode = '22222'
    @sender.username = 'user'
    @sender.password = 'pass'
  end

  after(:each) do
    EM::MockHttpRequest.deactivate!
  end

  it "should send a message" do
    EM.run do
      EM::MockHttpRequest.register_file("http://sms.mxtelecom.com:80/SMSSend?report=0&smsto=to&smsmsg=body&split=0&carrier=CINBELLUS&smsfrom=22222&pass=pass&flash=0&user=user", :get, ~'../processor/fixtures/twitter/send.txt')
      message = MessageGateway::SmsMessage.new('from', 'to', "body", 'clickatell')
      message.carrier_id = 'cincinnati_bell'
      @sender.add_login :cincinnati_bell, 'user', 'pass'
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