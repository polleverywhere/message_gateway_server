class MessageGateway
  class Sender

    class UnwiredAppeal
      include PhoneNumber

      attr_accessor :event_id, :password

      END_POINT_URL = 'http://appsrv.unwiredappeal.com/uwa_umap/eventhandler.srv'

      def send(message)
        request_object.get(self, END_POINT_URL,
            :query => {
                'evid'    => self.event_id,
                'pw'      => self.password,
                'carrier' => message.carrier,
                'number'  => canonicalize_phone_number(message.to),
                "msg"     => CGI.escape(message.body)
            }
        )
      end
    end
  end
end
