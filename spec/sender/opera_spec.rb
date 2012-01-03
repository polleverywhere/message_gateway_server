require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::Opera do
  before(:each) do
    @sender = MessageGateway::Sender::Opera.new
    @sender.init
    @sender.username = 'username'
    @sender.password = 'password'
    @sender.campaign_id = 'campaign_id'
    @sender.endpoint = 'http://thiismyendpoint:8080/'
  end


  it "should send a message" do
    EM.run do
      stub_request(:post, "http://thiismyendpoint:8080/")
          .to_return( :body => file_obj_for('processor/fixtures/twitter/send.txt'), :status => 200)

      #EM::MockHttpRequest.register_file(, :post, ~)
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
