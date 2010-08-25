require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::Clickatell do
  before(:each) do
    EM::MockHttpRequest.activate!
    EM::MockHttpRequest.pass_through_requests = false
    @sender = MessageGateway::Sender::Clickatell.new
    @sender.api_id = 'api_id'
    @sender.login = 'login'
    @sender.password = 'password'
  end

  after(:each) do
    EM::MockHttpRequest.deactivate!
  end

  it "should send a message" do
    EM.run do
      EM::MockHttpRequest.register_file("http://api.clickatell.com:80/http/sendmsg?mo=1&api_id=api_id&from=from&text=body&to=to&password=password&user=login", :get, ~'../processor/fixtures/twitter/send.txt')
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