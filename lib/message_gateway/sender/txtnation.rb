class MessageGateway
  class Sender
    class Txtnation < Sender
      attr_accessor :ekey, :company_code
      def send(message)
        defer_success_on_200(EM::HttpRequest.new('http://client.txtnation.com/mbill.php').post :data => { 'reply' => '', 'id' => '', 'network' => 'international', 'message' => message.body, 'cc' => @company_code, 'currency' => '', 'value' => '', 'number' => message.to })
      end

      def verify
        verify_params :ekey
      end
    end
  end
end
