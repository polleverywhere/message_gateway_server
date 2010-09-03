class MessageGateway
  class Sender
    class Smtp < Sender
      include PhoneNumber
      include Util::Carrier

      attr_accessor :opts

      def call(message)
        carrier = if message.respond_to?(:carrier)
          message.carrier
        elsif extra = Logger::State.find_extra_for_number(message.to)
          carrier_for_id(JSON.parse(extra)['carrier_id'])
        end

        if carrier and carrier.email?
          EM::Protocols::SmtpClient.send(opts.merge(:from=> message.from, :to=> [carrier.to_email(message.to)], :header=> {}, :body=> message.body))
        elsif carrier.nil?
          d = EM::DefaultDeferrable.new
          d.fail("This number does not have carrier info, or, no explict carrier was specified")
          d
        elsif !carrier.email?
          d = EM::DefaultDeferrable.new
          d.fail("This number does not have carrier info or carrier does not support smtp sending")
          d
        end
      end

    end
  end
end

