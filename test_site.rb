require 'sinatra'
require 'redis'

disable :show_exceptions

class NoServerYet < StandardError ; end

error NoServerYet do
  "No Redis server defined yet. Please run `heroku addons:add redisgreen:test`"
end


get '/' do
  contents = tabular redis.keys("*").map {|k| [k, redis.get(k)]}
  info = tabular redis.info

  <<-EOF
    <h1>RedisGreen Provisioning Test</h1>

    <br><br><br>
    #{contents}
    
    <form method="post" action="/set">
      <input type="text" name="key" value="key">
      <input type="text" name="value" value="value">
      <input type="submit" value="Add key">
    </form>

    <form method="post" action="/flush">
      <input type="submit" value="Clear Database">
    </form>

    <br><br>
    #{info}
  EOF
end

post '/set' do
  key = params[:key]
  value = params[:value]
  redis.set key, value
  redirect "/"
end

post "/flush" do
  redis.flushdb
  redirect "/"
end

def redis
  @redis ||= connect
end

def connect
  if url = ENV["REDISGREEN_URL"]
    Redis.new url: url
  else
    raise NoServerYet, "uh oh"
  end
end

def tabular(hash)
  hash.map {|k,v| "<b>#{k}</b>: #{v}<br>"}.join
end
