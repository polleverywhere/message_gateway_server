class MessageGateway
  class Sender
    class Twilio < Sender
      API_VERSION = '2010-04-01'

      attr_accessor :account_sid, :account_token, :message_is_from

      def send(message)
        twilio_send_url = "https://api.twilio.com/#{API_VERSION}/Accounts/#{@account_sid}/SMS/Messages"

        defer_success_on_200(  EM::HttpRequest.new(twilio_send_url).post(
          :data => { 'Body' => message.body, 
              'From' => @message_is_from, 'To' => canonicalize_phone_number(message.to) },
          :head => {'authorization' => [@account_sid, @account_token]} )  )
      end

      def verify
        
      end
    end # class Twilio
  end # class Sender
end # class MessageGateway
