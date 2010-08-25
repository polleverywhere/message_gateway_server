require 'spec_helper'
require 'dirge'

describe MessageGateway::Sender::Mblox do
  before(:each) do
    EM::MockHttpRequest.activate!
    EM::MockHttpRequest.pass_through_requests = false
    @sender = MessageGateway::Sender::Mblox.new
    @sender.username = 'username'
    @sender.password = 'password'
    @sender.shortcode = 'shortcode'
    @sender.profile_id = 'profile_id'
  end

  after(:each) do
    EM::MockHttpRequest.deactivate!
  end

  it "should send a message" do
    EM.run do
      EM::MockHttpRequest.register_file("http://xml5.us.mblox.com:8180/send", :post, ~'../processor/fixtures/twitter/send.txt')
      defer = @sender.call(MessageGateway::Message.new('from', 'to', "body", 'mblox'))
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
  
  it "should build a message" do
    @sender.build(MessageGateway::Message.new('from', 'to', "body", 'mblox')).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<NotificationRequest Version=\"3.5\">\n <NotificationHeader>\n  <PartnerName>username</PartnerName>\n  <PartnerPassword>password</PartnerPassword>\n </NotificationHeader>\n <NotificationList BatchID=\"9999999\">\n  <Notification SequenceNumber=\"1\" MessageType=\"SMS\">\n   <Message>body</Message>\n   <Profile>profile_id</Profile>\n   <SenderId Type=\"Shortcode\">from</SenderId>\n   <Subscriber>\n    <SubscriberNumber></SubscriberNumber>\n   </Subscriber>\n  </Notification>\n </NotificationList>\n</NotificationRequest>\n"
  end
end