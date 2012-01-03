class MessageGateway

  # AsyncRequest, and its sibling class SyncRequest, provides a strategy pattern for
  # hooking into how your Sender Subclass implementation talks to the Mobile Aggregator
  class AsyncRequest

    def post(sender_subclass, send_url, post_params)

      # Allow the caller to use the the older EM::HttpRequest API (which uses the data key)
      if post_params[:body].nil? && post_params[:data]
        post_params[:body] = post_params[:data]
      end

      defer_success_sym = sender_subclass.defer_callback_method
      sender_subclass.__send__(defer_success_sym, EM::HttpRequest.new(send_url).post(post_params) )
      # use __send__ instead of send to avoid clashing with Sender#send (which is defined)
    end


    def get(sender_subclass, send_url, get_params)
      defer_success_sym = sender_subclass.defer_callback_method
      sender_subclass.__send__(defer_success_sym, EM::HttpRequest.new(send_url).get(post_params) )
    end
  end
end
