require 'spec_helper'

describe MessageGateway::Parser::MxTelecom do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::MxTelecom.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = "mx_telecom"

       @message = parser.call(
          Rack::MockRequest.env_for("/?smsfrom=1234567890&smsto=52522&smsmsg=hello%20world%20this%20is%20a%20test&network=CRICKETUS")
      )
    end

    it "has a from of 1234567890" do
      @message.from.should == "1234567890"
    end

    it "has a to of 52522" do
      @message.to.should == "52522"
    end

    it "has a body as it should" do
      @message.body.should == "hello world this is a test"
    end

    it "has a carrier of CRICKETUS" do
      @message.carrier_id.should == :cricket_communications
    end
  end
end
