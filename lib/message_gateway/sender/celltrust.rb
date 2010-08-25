class MessageGateway
  class Sender
    class Celltrust < Sender
      attr_accessor :customer_nickname, :login, :password

      def send(message)
        defer_success_on_200(EM::HttpRequest.new('https://www.primemessage.net/TxTNotify/TxTNotify').get :data => {'PhoneDestination' => message.to, 'Message' => message.body, 'CustomerNickname' => customer_nickname, 'Username' => login, 'Password' => password})
      end
      
      def verify
        verify_params :customer_nickname, :login, :password
      end
    end
  end
end
