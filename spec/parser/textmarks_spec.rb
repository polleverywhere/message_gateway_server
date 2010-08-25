require 'spec_helper'

describe MessageGateway::Parser::Textmarks do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::Textmarks.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'textmarks'
      @message = parser.call(Rack::MockRequest.env_for('/?to=41411&from=1234561234&body=This+is+a+message'))
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

    it "should have a 'source' of 'textmarks'" do
      @message.source.should == 'textmarks'
    end
  end
end