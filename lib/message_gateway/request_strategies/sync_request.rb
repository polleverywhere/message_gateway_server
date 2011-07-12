class MessageGateway
  class SyncRequest
    def post(send_url, post_params)
      url = URI.parse(send_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if send_url =~ /https/

      http.start() do |http|
        puts "about to send to: #{url.path}"
        puts "posting: #{post_params[:data]}"

        req = Net::HTTP::Post.new(url.path)
        if post_params[:head]
          req.basic_auth post_params[:head]['authorization'][0], post_params[:head]['authorization'][1]
        end

        req.set_form_data( post_params[:data] )
        response = http.request(req)

        print response.body  # TODO: something better here
      end
    end
  end
end
