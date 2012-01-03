require 'builder'

class MessageGateway
  class Sender
    class Mblox < Sender
      include PhoneNumber

      attr_accessor :username, :password, :shortcode, :profile_id
      def send(message)
        request_object.post(self, 'http://xml5.us.mblox.com:8180/send', :data => { 'XMLDATA' => build(message) })
      end

      def build(message)
        out = ''
        xml = Builder::XmlMarkup.new(:target => out, :indent => 1)
        xml.instruct!
        xml.NotificationRequest(:Version => "3.5") { |nr|
          nr.NotificationHeader { |nh|
            nh.PartnerName(@username)
            nh.PartnerPassword(@password)
          }

          nr.NotificationList(:BatchID => "9999999") { |nl|
            nl.Notification(:SequenceNumber => "1", :MessageType => "SMS") { |n|
              n.Message(message.body)
              n.Profile(@profile_id)
              n.SenderId(message.from, :Type => 'Shortcode')
              n.Subscriber { |s|
                s.SubscriberNumber(canonicalize_phone_number(message.to))
              }
            }
          }
        }
        out
      end

      def verify
        verify_params :username, :password, :shortcode, :profile_id
      end
    end
  end
end

