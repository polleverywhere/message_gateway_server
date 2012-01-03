require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::Txtnation do
  before(:each) do
    #EM::MockHttpRequest.activate!
    #EM::MockHttpRequest.pass_through_requests = false

    stub_request(:any,
        "http://client.txtnation.com:80/mbill.php")
        .to_return( :body => file_obj_for('processor/fixtures/twitter/send.txt'), :status => 200 )

    @sender = MessageGateway::Sender::Txtnation.new
    @sender.init
    @sender.ekey = 'somekey'

    @sender.request_style.should == "async_request"
  end


  it "should send a message" do
    EM.run do
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
