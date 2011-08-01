class MessageGateway

  # AsyncRequest, and its sibling class SyncRequest, provides a strategy pattern for
  # hooking into how your Sender Subclass implementation talks to the Mobile Aggregator
  class AsyncRequest
  
    # TODO: need a GET method here too
    def post(sender_subclass, send_url, post_params)

      # Allow the caller to use the the older EM::HttpRequest API (which uses the data key)
      if post_params[:body].nil? && post_params[:data]
        post_params[:body] = post_params[:data]
      end

      sender_subclass.defer_success_on_201(  EM::HttpRequest.new(send_url).post(post_params) )
    end
  end
end
