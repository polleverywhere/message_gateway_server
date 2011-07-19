class MessageGateway
  class Sender

    # sends SMS messages via Twilio(.com).
    # NOTE: the FROM number in your message MUST be a number you bought in Twilio
    # (no, you can not spoof numbers)
    class Twilio < Sender
      include PhoneNumber

      API_VERSION = '2010-04-01'

      attr_accessor :account_sid, :account_token, :default_from

      def send(message)
        twilio_send_url = "https://api.twilio.com/#{API_VERSION}/Accounts/#{@account_sid}/SMS/Messages"

        request_object.post( self, twilio_send_url, 
          :data => { 'Body' => message.body, 
              'From' => message.from || default_from, 'To' => canonicalize_phone_number(message.to) },
          :head => {'authorization' => [@account_sid, @account_token]} )
      end

      def verify
        
      end
    end # class Twilio
  end # class Sender
end # class MessageGateway
