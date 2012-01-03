require 'spec_helper'
require 'dirge'


describe MessageGateway::Sender::Celltrust do
  before(:each) do
    stub_request(:any, "https://www.primemessage.net:443/TxTNotify/TxTNotify").to_return(
        :body => file_obj_for('processor/fixtures/twitter/send.txt'), :status => 200)

    @sender = MessageGateway::Sender::Celltrust.new
    @sender.init
    @sender.customer_nickname = 'nickname'
    @sender.login = 'login'
    @sender.password = 'password'
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
