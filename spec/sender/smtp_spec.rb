require 'spec_helper'
require 'dirge'
require 'mocha'

describe MessageGateway::Sender::Smtp do
  before(:each) do
    @sender = MessageGateway::Sender::Smtp.new
    @sender.opts = {}
    defer = EM::DefaultDeferrable.new
    defer.succeed
    defer
    EM::Protocols::SmtpClient.expects(:send).with({:to=>["1231231234@txt.att.net"], :from=>"41411", :body=>"body", :header=>{}}).returns(defer)
  end

  it "should send a message" do
    EM.run do
      message = MessageGateway::SmsMessage.new('41411', '1231231234', "body", 'mblox')
      message.carrier_id = :att
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