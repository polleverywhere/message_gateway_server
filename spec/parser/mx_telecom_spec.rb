require 'spec_helper'

describe MessageGateway::Parser::MxTelecom do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::MxTelecom.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'mxtelecom'
      @message = parser.call(Rack::MockRequest.env_for('/?smsto=41411&smsfrom=1234561234&smsmsg=This+is+a+message&network=GCIUS'))
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
      @message.source.should == 'mxtelecom'
    end

    it "should have a 'carrier_id' of :gci" do
      @message.carrier_id.should == :gci
    end
  end
end