require 'sinatra'
require 'redis'

disable :show_exceptions

class NoServerYet < StandardError ; end

error NoServerYet do
  "No Redis server defined yet. Please run `heroku addons:add redisgreen:test`"
end

error Redis::CannotConnectError do
  "I can't connect to the Redis server. Contact support?"
end

error Redis::CommandError do
  "Got an error from Redis - perhaps you've run out of memory?"
end

get '/' do

  <<-EOF
    <h1>RedisGreen Provisioning Test</h1>

    <br><br><br>
    #{tabular contents}
    
    <form method="post" action="/set">
      <input type="text" name="key" value="key">
      <input type="text" name="value" value="value">
      <input type="submit" value="Add key">
    </form>

    <form method="post" action="/bulk_add">
      <input type="submit" value="Add #{bulk_size} keys">
    </form>

    <form method="post" action="/flush">
      <input type="submit" value="Clear Database">
    </form>

    <br><br>
    #{tabular info}
  EOF
end

post '/set' do
  key = params[:key]
  value = params[:value]
  redis.set "kv:#{key}", value
  redirect "/"
end

post "/flush" do
  redis.flushdb
  redirect "/"
end

post "/bulk_add" do
  ts = Time.now.to_i
  redis.pipelined do
    bulk_size.times do |i|
      redis.set "bulk:#{ts}:#{i}", i
    end
  end
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

def contents
  redis.keys("kv:*").map do |k|
    [k.split(":", 2).last, redis.get(k)]
  end
end

def info
  redis.info.find_all do |k,v|
    k =~ /human/ || k == "db0"
  end
end

def tabular(hash)
  hash.map {|k,v| "<b>#{k}</b>: #{v}<br>"}.join
end

def bulk_size
  50000
end
