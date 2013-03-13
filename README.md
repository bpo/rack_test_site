# rack_test_site #

A simple Rack test app, used to check how quickly RedisGreen servers spin up on
Heroku. Allows anyone who accesses it to add arbitrary keys, or batch add large
numbers at once.

## Configuration ##

The only used external resource is a Redis server, configured with the
environment variable of `REDISGREEN_URL`.

