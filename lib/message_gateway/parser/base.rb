class MessageGateway
  module Parser
    class Base
      include Parser
      attr_accessor :default_to
      def initialize(&blk)
        yield self if blk
      end
    end
  end
end