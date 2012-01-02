require 'spec_helper'
require 'dirge'
require 'nokogiri'

describe MessageGateway::Sender::Mblox do
  before(:each) do
    EM::MockHttpRequest.activate!
    EM::MockHttpRequest.pass_through_requests = false

    @sender = MessageGateway::Sender::Mblox.new
    @sender.init
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
    doc = Nokogiri::XML(@sender.build(MessageGateway::Message.new('41414', '12121234123', "body", 'mblox')))
    doc.xpath('//NotificationRequest/NotificationList/Notification/Message').inner_text.should == 'body'
    doc.xpath('//NotificationRequest/NotificationList/Notification/SenderId').inner_text.should == '41414'
    doc.xpath('//NotificationRequest/NotificationList/Notification/Subscriber/SubscriberNumber').inner_text.should == '12121234123'
  end
end
