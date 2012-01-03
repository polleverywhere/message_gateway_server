class MessageGateway
  module Middleware

    # A middleware class that avoids the MySQL gone away type errors
    #
    # TODO: It could/should be refactored a bit to be less... aggressive.
    # (clear_active_connections may be blocking, for example)
    class KeepDbConnectionAlive

      def initialize(app)
        @app = app
      end

      def call(env)
        ActiveRecord::Base.clear_active_connections!

        @app.call(env)
      end
    end
  end
end
