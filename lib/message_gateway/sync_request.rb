class MessageGateway
  class SyncRequest
    def post(send_url, post_params)
      url = URI.parse(send_url)
      Net::HTTP.start(url.host, url.port) do |http|
        req = Net::HTTP.Post.new(url.path)
        if post_params[:head]
          req.basic_auth post_params[:head]['authorization'][[0], post_params[:head]['authorization'][[1]
        end
        req.set_form_data( post_params[:data], ';' )
        response = http.request(req)

        print response.body  # TODO: something better here
      end
    end
  end
end
