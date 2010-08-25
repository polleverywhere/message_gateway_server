class MessageGateway
  class Sender
    class UnwiredAppeal < Sender
      include Util::Carrier

      import_carrier_mappings MessageGateway::Parser::UnwiredAppeal

      attr_accessor :event_id, :password
      def send(message)
        defer_success_on_200(EM::HttpRequest.new('http://appsrv.unwiredappeal.com/uwa_umap/eventhandler.srv').get :query => { 'evid' => @event_id, 'pw' => @password, 'carrier' => message.carrier ? denormalize_carrier(message.carrier) : '', 'msg' => message.body, 'number' => canonicalize_phone_number(message.to) })
      end

      def verify
        verify_params :event_id, :password
      end
    end
  end
end
