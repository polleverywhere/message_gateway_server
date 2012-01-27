require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::Clickatell do
  before :each do
    stub_request(:any,
      "http://api.clickatell.com:80/http/sendmsg?mo=1&api_id=api_id&from=from&text=body&to=to&password=password&user=login")
      .to_return(:body => file_obj_for('processor/fixtures/twitter/send.txt'))

    @sender = MessageGateway::Sender::Clickatell.new
    @sender.init
    @sender.api_id   = 'api_id'
    @sender.login    = 'login'
    @sender.password = 'password'
  end

  it "should send a message" do
    EM.run do
      defer = @sender.call(MessageGateway::Message.new('from', 'to', "body", 'clickatell'))
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
