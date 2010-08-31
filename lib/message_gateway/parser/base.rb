class MessageGateway
  module Parser
    class Base
      include Parser
      def initialize(&blk)
        yield self if blk
      end
    end
  end
end