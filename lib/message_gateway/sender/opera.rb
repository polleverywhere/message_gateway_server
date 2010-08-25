class MessageGateway
  class Sender
    class Opera < Sender

      include Util::Carrier
      import_carrier_mappings MessageGateway::Parser::Opera

      attr_accessor :username, :password, :campaign_id, :endpoint

      def verify
        verify_params :username, :password, :campaign_id, :endpoint
      end

      def send(message)
        defer_success_on_200(EM::HttpRequest.new(endpoint).post :data => {
         'CampaignID'   => @campaign_id,
         'Username'     => @username,
         'Password'     => @password,
         'Channel'      => denormalize_carrier(message.carrier),
         'MSISDN'       => message.to,
         'Content'      => message.body
        })
      end
    end
  end
end
