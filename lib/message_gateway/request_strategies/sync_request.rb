class MessageGateway
  class SyncRequest
    def post(sender_subclass, send_url, post_params)
      url = URI.parse(send_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if send_url =~ /https/

      # Allow the caller to use the the older EM::HttpRequest API (which uses the data key)
      if post_params[:body].nil? && post_params[:data]
        post_params[:body] = post_params[:data]
      end

      http.start() do |http|
        puts "about to send to: #{url.path}"
        puts "posting: #{post_params[:body]}"

        req = Net::HTTP::Post.new(url.path)
        if post_params[:head]
          req.basic_auth post_params[:head]['authorization'][0], post_params[:head]['authorization'][1]
        end

        req.set_form_data( post_params[:body] )
        response = http.request(req)

        print response.body  # TODO: something better here
      end
    end
  end
end
