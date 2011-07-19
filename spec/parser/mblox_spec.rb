require 'spec_helper'

describe MessageGateway::Parser::Mblox do
  context "parsing a valid message" do
    before(:each) do
      text = <<-HERE_DOC
<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<ResponseService Version="2.3">
  <Header>
    <Partner>UserName</Partner>
    <Password>Password</Password>
    <ServiceID>1</ServiceID>
  </Header>
  <ResponseList>
    <Response SequenceNumber="1" Type="SMS" Format="Text">
      <TransactionID>215980</TransactionID>
      <OriginatingNumber>1234561234</OriginatingNumber>
      <Time>200412181427</Time>
      <Data>This is a message</Data>
      <Deliverer>31006</Deliverer>
      <Destination>41411</Destination>
      <Operator>99999</Operator>
      <Tariff>150</Tariff>
      <SessionId>SessionID</SessionId>
      <Tags>
        <Tag Name=”Number”>12</Tag>
        <Tag Name=”City”>Rome</Tag>
      </Tags>
    </Response>
  </ResponseList>
</ResponseService>
      HERE_DOC
      parser = MessageGateway::Parser::Mblox.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'mblox'
      @message = parser.call(Rack::MockRequest.env_for('/', :method => 'POST', 
        :params => {"xmldata" => text}))
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

    it "should have a 'source' of 'mblox'" do
      @message.source.should == 'mblox'
    end

    it "should have a 'carrier_id' of :dobson_att" do
      @message.carrier_id.should == :dobson_att
    end
  end
end