require 'spec_helper'

describe MessageGateway::Parser::Celltrust do
  context "parsing a valid message" do
    before(:each) do
      text = <<-HERE_DOC
  <?xml version="1.0" encoding="UTF-8"?>
  <RecipientResponse pm_version="1_0">
    <Nickname>SAYTO</Nickname>
    <Data>This is a message</Data>
    <Message type="TEXT">Sayto @This is a message</Message>
    <DeliveryType>SMS</DeliveryType>
    <Carrier>cingular</Carrier>
    <NetworkType>gsm</NetworkType>
    <ResponseType>NORMAL</ResponseType>
    <OriginatorAddress>123-456-1234</OriginatorAddress>
    <ServerAddress>41411</ServerAddress>
    <AcceptedTime>
      <DateTime>
        <DateFormat>dd/MMM/yyyy HH:mm:ss</DateFormat>
        <Date><%= Time.now %></Date>
      </DateTime>
    </AcceptedTime>
  </RecipientResponse>
      HERE_DOC
      parser = MessageGateway::Parser::Celltrust.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'celltrust'
      @message = parser.call(Rack::MockRequest.env_for('/', :method => 'POST', :params => {"xml" => text}))
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
      @message.source.should == 'celltrust'
    end

    it "should have a 'carrier' of :cingular" do
      @message.carrier_id.should == :att_mobility
    end
  end
end