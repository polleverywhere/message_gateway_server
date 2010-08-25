require 'spec_helper'

describe MessageGateway::Parser::Clickatell do
  context "parsing a valid message" do
    before(:each) do
      text = <<-HERE_DOC
<?xml version="1.0"?> 
<clickmo> 
    <api_id>xxx</api_id> 
    <moMsgId>121910921</moMsgId> 
    <from>41411</from> 
    <to>1234561234</to> 
    <timestamp>#{Time.now}</timestamp> 
    <text>This is a message</text> 
    <charset>ISO-8859-1</charset>
    <udh></udh> 
</clickmo>
      HERE_DOC
      parser = MessageGateway::Parser::Clickatell.new
      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'clickatell'
      @message = parser.call(Rack::MockRequest.env_for('/', :method => 'POST', :params => {:data => text}))
    end
    
    it "should have a 'from' of '41411'" do
      @message.from.should == '41411'
    end

    it "should have a 'to' of '1234561234'" do
      @message.to.should == '1234561234'
    end

    it "should have a 'body' of 'This is a message'" do
      @message.body.should == 'This is a message'
    end

    it "should have a 'source' of 'clickatell'" do
      @message.source.should == 'clickatell'
    end
  end
end