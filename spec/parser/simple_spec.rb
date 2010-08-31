require 'spec_helper'

describe MessageGateway::Parser::Simple do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::Simple.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'simple'
      @message = parser.call(Rack::MockRequest.env_for('/?receiver=41411&sender=1234561234&body=This+is+a+message'))
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

    it "should have a 'source' of 'simple'" do
      @message.source.should == 'simple'
    end
  end

  context "using a default_to" do
    before(:each) do
      parser = MessageGateway::Parser::Simple.new
      parser.default_to = "41411"
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'simple'
      @message = parser.call(Rack::MockRequest.env_for('/?sender=1234561234&body=This+is+a+message'))
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

    it "should have a 'source' of 'simple'" do
      @message.source.should == 'simple'
    end
  end

end