require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::Mblox do
  before(:each) do
    EM::MockHttpRequest.activate!
    EM::MockHttpRequest.pass_through_requests = false
    @sender = MessageGateway::Sender::Txtnation.new
    @sender.init
    @sender.ekey = 'somekey'
  end

  after(:each) do
    EM::MockHttpRequest.deactivate!
  end

  it "should send a message" do
    EM.run do
      EM::MockHttpRequest.register_file("http://client.txtnation.com:80/mbill.php", :post, ~'../processor/fixtures/twitter/send.txt')
      defer = @sender.call(MessageGateway::Message.new('from', 'to', "body", 'txtnation'))
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