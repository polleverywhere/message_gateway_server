require 'spec_helper'

describe MessageGateway::Parser::UnwiredAppeal do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::UnwiredAppeal.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'unwired_appeal'
      @message = parser.call(Rack::MockRequest.env_for('/?carrier=12&sender=1234561234&receiver=41411&body=This+is+a+message'))
    end
    
    it "should have a 'to' of '41411'" do
      @message.to.should == '41411'
    end

    it "should have a 'from' of '1234561234'" do
      @message.from.should == '1234561234'
    end

    it "should have a 'body' of 'This is a message'" do
      @message.body.should == 'This is a message'
    end

    it "should have a 'source' of 'unwired_appeal'" do
      @message.source.should == 'unwired_appeal'
    end

    it "should have a 'carrier_id' of :virgin_mobile" do
      @message.carrier_id.should == :virgin_mobile
    end
  end
end