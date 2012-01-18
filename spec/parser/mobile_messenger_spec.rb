require 'spec_helper'

describe MessageGateway::Parser::MobileMessenger do
  context "parsing a valid message" do
    before(:each) do
      parser = MessageGateway::Parser::MobileMessenger.new

      parser.processor = MessageGateway::Processor.new
      parser.processor.name = 'mobile_messsenger'

      message_params = 'dialog.message=myguy++toughest+job+might+be+any+head+coaching+job+at+a+top+tier+sec+football+school++no+one+remembers+a+national+title+two+years+later++thanks%2C+Eric&serviceCode=22333&dialog.carrier_id=4&senderState=NotAvailable&sender=6145076621&carrierId=4&content=myguy++toughest+job+might+be+any+head+coaching+job+at+a+top+tier+sec+football+school++no+one+remembers+a+national+title+two+years+later++thanks%2C+Eric&dialog.service_code=22333&dialog.umda=tel%3A6145076621&messageId=07n9g8i1me4j8021m2usb6b9qsnd&senderCity=NotAvailable'
      test_req = Rack::MockRequest.env_for( "/",  #?#{message_params}"
        :input => message_params,
        "REQUEST_METHOD" => "POST")

      @message = parser.call test_req
      require 'ruby-debug'
      debugger
      @message.should_not be_nil
    end

    it "has the supplied body" do
      @message.body.should == "myguy  toughest job might be any head coaching job at a top tier sec football school  no one remembers a national title two years later  thanks, Eric"
    end

    it "has the supplied from number" do
      @message.from.should == "6145076621"
    end

    it "has the supplied to number" do
      @message.to.should == "22333"
    end
  end
end
