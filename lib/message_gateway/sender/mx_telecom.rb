class MessageGateway
  class Sender
    class MxTelecom < Sender

      include Util::Carrier
      import_carrier_mappings MessageGateway::Parser::MxTelecom

      END_POINT_URL = 'http://sms.mxtelecom.com/SMSSend'
      attr_accessor :username, :password, :shortcode, :split, :flash, :report

      def initialize
        @flash, @split, @report = "0", "0", "0"
        @mt_carrier_logins = {}
        yield self if block_given?
      end

      def add_login(id, user, password)
        raise "Cannot find carrier #{id}" unless carrier_for_id(id)
        @mt_carrier_logins[carrier_for_id(id)] = [user, password]
      end

      def verify
        verify_params :shortcode, :username, :password
      end

      def send(message)
        user, password = message.respond_to?(:carrier) && message.carrier && @mt_carrier_logins[message.carrier] ?
          @mt_carrier_logins[message.carrier] :
          [@user, @password]

        raise "user must be set or derived from add_login"      unless user
        raise "password must be set or derived from add_login"  unless password

        defer_success_on_200(EM::HttpRequest.new(END_POINT_URL).get :query => {'user' => user, 'pass' => password, 'smsfrom' => @shortcode, 'carrier' => message.carrier ? denormalize_carrier(message.carrier) : '', 'smsto' => message.to, 'smsmsg' => message.body, 'split' => @split, 'flash' => @flash, 'report' => @report})
      end
    end
  end
end
