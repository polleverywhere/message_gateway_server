require 'spec_helper'

describe MessageGateway::Message do
  it "should to_hash" do
    MessageGateway::Message.new("from", "to", "body", "source", 1).to_hash.should ==
      {:from => 'from', :to => 'to', :body => 'body', :source => 'source', :in_reply_to => 1}
  end

  context "should from_hash" do
    before(:each) do
      @message = MessageGateway::Message.from_hash('from' => 'from', 'to' => 'to', 'body' => 'body', 'source' => 'source', 'in_reply_to' => 1)
    end

    it "should have from"        do; @message.from.should == 'from';      end
    it "should have to"          do; @message.to.should == 'to';          end
    it "should have body"        do; @message.body.should == 'body';      end
    it "should have source"      do; @message.source.should == 'source';  end
    it "should have in_reply_to" do; @message.in_reply_to.should == 1;    end
  end
end
  
describe MessageGateway::SmsMessage do
  it "should to_hash" do
    message = MessageGateway::SmsMessage.new("from", "to", "body", "source", 1)
    message.carrier_id = :verizon
    
    message.to_hash.should ==
      {:from => 'from', :to => 'to', :body => 'body', :source => 'source', :in_reply_to => 1, "carrier_id" => :verizon}
  end

  
  context "should from_hash" do
    before(:each) do
      @message = MessageGateway::Message.from_hash('from' => 'from', 'to' => 'to', 'body' => 'body', 'source' => 'source', 'in_reply_to' => 1)
    end

    it "should have from"        do; @message.from.should == 'from';      end
    it "should have to"          do; @message.to.should == 'to';          end
    it "should have body"        do; @message.body.should == 'body';      end
    it "should have source"      do; @message.source.should == 'source';  end
    it "should have in_reply_to" do; @message.in_reply_to.should == 1;    end
  end
end
  
