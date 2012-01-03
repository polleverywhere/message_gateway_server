class MessageGateway
  module Middleware

    autoload :KeepDbConnectionAlive, 'message_gateway/middleware/keep_db_connection_alive'
  end
end
