require 'spec_helper'

describe MessageGateway::Parser::Twilio do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::Twilio.new

      #parser.prefix = 'ask poll'
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'twilio'
      @message = parser.call(Rack::MockRequest.env_for(
        '/?SmsSid=125345654323456&AccountSid=1234561234&Body=ask+poll+This+is+a+message&From=123456789&To=987654321'))
    end

    it "has a body of 'ask poll this is a message'" do
      @message.body.should == "ask poll This is a message"
    end

    it "has a From number of 123456789" do
      @message.from.should == "123456789"
    end

    it "has a To number of 987654321" do
      @message.to.should == "987654321"
    end
  end
end
