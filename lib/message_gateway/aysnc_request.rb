class MessageGateway

  class AsyncRequest
    def post(send_url, post_params)
      defer_success_on_200(  EM::HttpRequest.new(send_url).post(post_params) )
    end
  end
end