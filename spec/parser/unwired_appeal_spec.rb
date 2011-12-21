require 'spec_helper'

describe MessageGateway::Parser::UnwiredAppeal do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::UnwiredAppeal.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = "unwired_appeal"

      @message = parser.call(
          Rack::MockRequest.env_for("/?sender=my_sender&receiver=41411&body=This%20is%20a%20test&carrier=12")
      )
    end

    it "should have a from of my_sender" do
      @message.from.should == "my_sender"
    end

    it "has a 'to' of 41411" do
      @message.to.should == "41411"
    end

    it "has a source of unwired_appeal" do
      @message.source.should == "unwired_appeal"
    end

    it "has a carrier of virgin_mobile" do
      @message.carrier_id.should == :virgin_mobile
    end
  end
end
