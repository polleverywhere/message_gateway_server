$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'message_gateway'

MessageGateway.default_logger = MessageGateway::Logger.new(:adapter => "mysql", :host => "localhost", :database => "message_gateway_test", :username => "root", :password => "")
MessageGateway.default_logger.reset!(true)

#Thin::Logging.silent = true

def start_gateway(name = 'test', endpoint = "http://127.0.0.1:8999/sms")
  MessageGateway.new(name, endpoint)
end

def start_processor(port = 3456)
  gateway = start_gateway
  Thin::Server.new('0.0.0.0', port) do
    run yield gateway
  end.start
  gateway
end

def start_backend(port = 8999, &blk)
  server = Thin::Server.new('0.0.0.0', port) do
    run blk
  end
  server.start!
  server
end

def test_processor(&blk)
  http = EM::HttpRequest.new('http://127.0.0.1:3456/').get :timeout => 1
  http.errback {|err| puts err.inspect; EM.stop; raise}
  http
end

def create_parser(&proc)
  parser = Class.new do
    include MessageGateway::Parser
    define_method(:call, &proc)
  end.new
  parser
end

def create_sender(&proc)
  sender = Class.new(MessageGateway::Sender) do
    define_method(:call, &proc)
  end.new
  sender
end

def restart_beanstalkd
  stop_beanstalkd
  `beanstalkd -d`
end

def stop_beanstalkd
  `killall beanstalkd`
end

def sample_tweet_data
  JSON.parse <<-JSON_DATA
{
  "coordinates": null,
  "favorited": false,
  "created_at": "Thu Jul 15 23:26:44 +0000 2010",
  "truncated": false,
  "text": "@poll 21222",
  "contributors": null,
  "id": 18639485000,
  "geo": null,
  "in_reply_to_user_id": null,
  "place": null,
  "in_reply_to_screen_name": null,
  "user": {
    "name": "paul isaias gallegos",
    "profile_sidebar_border_color": "eeeeee",
    "profile_background_tile": false,
    "profile_sidebar_fill_color": "efefef",
    "created_at": "Sun Jun 06 19:56:50 +0000 2010",
    "profile_image_url": "http://a1.twimg.com/profile_images/972549385/m_e26ddd7e7a424fdebceef1b3d005011f_normal.jpg",
    "location": "",
    "profile_link_color": "009999",
    "follow_request_sent": null,
    "url": null,
    "favourites_count": 0,
    "contributors_enabled": false,
    "utc_offset": -21600,
    "id": 152752917,
    "profile_use_background_image": true,
    "profile_text_color": "333333",
    "protected": false,
    "followers_count": 1,
    "lang": "es",
    "notifications": null,
    "time_zone": "Central Time (US & Canada)",
    "verified": false,
    "profile_background_color": "131516",
    "geo_enabled": false,
    "description": "",
    "friends_count": 2,
    "statuses_count": 18,
    "profile_background_image_url": "http://a3.twimg.com/profile_background_images/122541097/m_4011538d4b734ec7923bd641d2fa274f.jpg",
    "following": null,
    "screen_name": "izaloko"
  },
  "source": "web",
  "in_reply_to_status_id": null
}
  JSON_DATA
end

class Chirpstream
  def initialize(opts)
  end

  def connect_single(user)
    @user = user
  end
  
  def on_tweet(&proc)
    EM.add_timer(0.3) { proc.call(Chirpstream::Tweet.new(self, sample_tweet_data), @user) }
  end
  
  def on_reconnect
  end
  
  def on_connect
  end
end
