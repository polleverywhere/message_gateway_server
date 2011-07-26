class MessageGateway
  class Sender
    class Txtnation < Sender
      attr_accessor :ekey, :company_code
      def send(message)
        request_object.post( self, 'http://client.txtnation.com/mbill.php',
          :data => { 'reply' => '', 'id' => '', 'network' => 'international', 'message' => message.body, 'cc' => @company_code, 'ekey' => @ekey, 'currency' => '', 'value' => '', 'number' => message.to
          }
        )
      end

      def verify
        verify_params :ekey
      end
    end
  end
end
