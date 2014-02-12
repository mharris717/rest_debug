# RestDebug

To start a server and client:

Install rest_debug

```
gem install rest_debug
```

Start the server

```
rest_debug -p 7000
```

Start the client

```
require 'rest_debug'
client = RestDebug::Client.new(:base_url => "http://localhost:7000")
client.start "puts :abc"
client.status
client.command :continue
client.status
```
