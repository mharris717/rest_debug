= rest_debug

Description goes here.

== Contributing to rest_debug
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2014 Mike Harris. See LICENSE.txt for
further details.

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

This library is intended to be used with Ember.js and the 
[ember-auth-easy](http://github.com/mharris717/ember-auth-easy) javascript library.

It adds token authentication to your Rails app (thanks Devise!).

## Adding EAR to your Rails app.

* Add ember_auth_rails to your gemfile

```
gem 'ember_auth_rails'
```
