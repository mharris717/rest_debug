require 'pp'
load "lib/rest_debug.rb"

url = "http://localhost:7000"
client = RestDebug::Client.new(:base_url => url)

client.start "puts :abc"
client.status
client.command :continue
pp client.status