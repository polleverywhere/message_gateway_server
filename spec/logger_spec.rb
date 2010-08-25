require 'spec_helper'

describe MessageGateway::Logger do
  before(:each) do
    @logger = MessageGateway.default_logger
    @logger.soft_reset!
  end

  it "should log a message" do
    state = @logger.record_status(MessageGateway::Message.from_hash('from' => 'from', 'to' => 'to', 'body' => 'body', 'source' => 'source'), "start")
    state.from.should == 'from'
    state.to.should == 'to'
    state.body.should == 'body'
    state.source.should == 'source'
    state.status.should == 'start'
    state.extra.should be_nil
  end

  it "should log a message with extra" do
    state = @logger.record_status(MessageGateway::SmsMessage.from_hash('from' => 'from', 'to' => 'to', 'body' => 'body', 'source' => 'source', 'carrier_id' => "hellothere"), "start")
    state.from.should == 'from'
    state.to.should == 'to'
    state.body.should == 'body'
    state.source.should == 'source'
    state.status.should == 'start'
    JSON.parse(state.extra).should == {'carrier_id' => 'hellothere'}
  end

  it "should update a message" do
    message = MessageGateway::Message.from_hash('from' => 'from', 'to' => 'to', 'body' => 'body', 'source' => 'source')
    @logger.record_status(message, "start")
    @logger.record_status(message, "start2")
    @logger.record_status(message, "start3")
    MessageGateway::Logger::State.count.should == 1
    MessageGateway::Logger::Event.count.should == 3
    MessageGateway::Logger::State.find_by_message(message).events.size.should == 3
  end

  it "should record the reply chain" do
    message = MessageGateway::Message.from_hash('from' => 'from', 'to' => 'to', 'body' => 'body', 'source' => 'source')
    @logger.record_status(message, "start")
    reply_message = message.reply('no, you suck!')
    @logger.record_status(reply_message, "start")
    
    MessageGateway::Logger::State.find(reply_message.id).replied_from.body.should == 'body'
    MessageGateway::Logger::State.find(message.id).reply.body.should == 'no, you suck!'
    MessageGateway::Logger::State.find(reply_message.id).reply.should be_nil
    MessageGateway::Logger::State.find(message.id).replied_from.should be_nil
  end

  it "should record a detailed error with it" do
    message = MessageGateway::Message.from_hash('from' => 'from', 'to' => 'to', 'body' => 'body', 'source' => 'source')
    state = @logger.record_status(message, "start", "detailed error")
    state.events.size.should == 1
    state.events.first.error.should == "detailed error"
  end
end