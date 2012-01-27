class MessageGateway
  class Sender
    class Clickatell < Sender
      attr_accessor :api_id, :login, :password
      def send(message)
        defer_success_on_200(
          EM::HttpRequest.new('http://api.clickatell.com/http/sendmsg').get :query => {
            'api_id'   => @api_id,
            'user'     => @login,
            'password' => @password,
            'mo'       => '1',
            'from'     => message.from,
            'to'       => message.to,
            'text'     => message.body
          }
        )
      end

      def verify
        verify_params :api_id, :login, :password
      end
    end
  end
end

