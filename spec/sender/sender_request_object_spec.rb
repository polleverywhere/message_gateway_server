require 'spec_helper'

class MessageGateway
  class MockRequestor
  end
end

describe MessageGateway::Sender do

  describe "creating a request object strategy pattern" do
    before(:each) do
    end

    it "creates a default request object" do
      sender = MessageGateway::Sender.new
      sender.init

      sender.request_object.should be_a_kind_of(MessageGateway::AsyncRequest)
    end

    it "creates a type of the request object specified" do
      sender = MessageGateway::Sender.new
      sender.init do |s|
        s.request_style = "mock_requestor"
      end

      sender.request_object.should be_a_kind_of(MessageGateway::MockRequestor)
    end
  end  
end
