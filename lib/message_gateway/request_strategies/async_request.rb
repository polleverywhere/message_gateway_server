class MessageGateway

  # AsyncRequest, and its sibling class SyncRequest, provides a strategy pattern for
  # hooking into how your Sender Subclass implementation talks to the Mobile Aggregator
  class AsyncRequest
  
    # TODO: need a GET method here too
    def post(sender_subclass, send_url, post_params)
      sender_subclass.defer_success_on_200(  EM::HttpRequest.new(send_url).post(post_params) )
    end
  end
end