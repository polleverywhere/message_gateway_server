class MessageGateway
  class Sender
    class MobileMessenger < Sender
      attr_accessor :user, :password, :shortcode
      def send(message)
        defer_success_on_200(  EM::HttpRequest.new("https://sendsms.mobilemessenger.com/wsgw/sendSingle").post(
          :data => { 'message' => message.body, 'serviceCode' => @shortcode, 'destination' => canonicalize_phone_number(message.to) },
          :head => {'authorization' => [@user, @password]} )  )
      end

      def verify
        verify_params :user, :password, :shortcode
      end
    end
  end
end
