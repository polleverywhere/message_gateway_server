require 'spec_helper'

describe MessageGateway::Parser::Opera do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::Opera.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'opera'
      @message = parser.call(Rack::MockRequest.env_for('/?shortcode=41411&msisdn=1234561234&content=This+is+a+message&channel=IRELAND.3'))
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

    it "should have a 'source' of 'mxtelecom'" do
      @message.source.should == 'opera'
    end

    it "should have a 'carrier_id' of :ireland_3" do
      @message.carrier_id.should == :ireland_3
    end
  end
end