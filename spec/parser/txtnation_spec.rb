require 'spec_helper'

describe MessageGateway::Parser::Txtnation do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::Txtnation.new
      parser.prefix = 'ask poll'
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'txtnation'
      @message = parser.call(Rack::MockRequest.env_for('/?shortcode=41411&number=1234561234&message=ask+poll+This+is+a+message'))
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

    it "should have a 'source' of 'txtnation'" do
      @message.source.should == 'txtnation'
    end
  end
end