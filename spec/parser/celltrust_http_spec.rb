require 'spec_helper'

describe MessageGateway::Parser::CelltrustHttp do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::CelltrustHttp.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'celltrust_http'
      @message = parser.call(Rack::MockRequest.env_for('/?OriginatorAddress=1234561234&ServerAddress=41411&Message=This+is+a+message&Carrier=centennial'))
    end
    
    it "should have a 'from' of '1234561234'" do
      @message.from.should == '1234561234'
    end

    it "should have a 'to' of '41411'" do
      @message.to.should == '41411'
    end

    it "should have a 'body' of 'This is a message'" do
      @message.body.should == 'This is a message'
    end

    it "should have a 'source' of 'celltrust'" do
      @message.source.should == 'celltrust_http'
    end

    it "should have a 'carrier' of :centennial_wireless" do
      @message.carrier_id.should == :centennial_wireless
    end
  end
end