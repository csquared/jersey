# Jersey

<img src="http://geology.com/state-map/maps/new-jersey-physical-map.gif" height="200px" />

Because [worse is better](http://en.wikipedia.org/wiki/Worse_is_better).

Jersey is a gem for people who want to write excellent APIs but have their
own opinions on how to structure their code and projects.

Jersey provides sensible defaults that are composed with sensible pieces, making
it easy to compose your own stack or use Jesery's compositions.

## Features
  - env-conf for easy ENV based configuration
  - secure ENV loading mechanism
  - request context aware request logging
  - structured data loggers - json and logfmt
  - unified exception handling

### `Jersey.setup`

Setup embodies a few opinions we have about apps:
- Having a notion of 'environment' where the configuration lives
- Using a dependency manager
- Always using UTC for the Time zone
- Always printing times in ISO8601 format

`Jersey.setup` allows any app that has Gemfiles and `.env` files to
"just work" in development *and* production with just:

```ruby
require 'jersey'
Jersey.setup
```

Which is usually included as the first line of code in a library consuming
Jersey.  For tests, you will want to set `RACK_ENV` to `test` before
requiring your library that uses the above.

### `Jersey::API::Base`

Combines all of the Jersey middleware with a few standard middleware
from Rack and sinatra-contrib.

```ruby
class API < Jersey::API::Base
  get '/hello' do
    Jersey.log(at: "hello")
    'hello'
  end

  get '/not_found' do
    raise NotFound, "y u no here?"
  end
end
```


```
$ curl http://localhost:9292/hello
```

Server logs:
```
at=start method=GET path=/hello request_id=2c018557-d246-4b04-a7d7-fc74bae67ec0 now=2014-11-11T18:04:25+00:00
at=hello now=2014-11-11T18:04:25+00:00 request_id=2c018557-d246-4b04-a7d7-fc74bae67ec0
at=finish method=GET path=/hello status=200 size#bytes=5 route_signature=/hello elapsed=0.000 request_id=2c018557-d246-4b04-a7d7-fc74bae67ec0 now=2014-11-11T18:04:25+00:00
```

Unified, structured logging with all the info you will wish you had:

```
$ curl http://localhost:9292/not_found | jq '.'
```

Server logs:
```
at=start method=GET path=/not_found request_id=f3085630-05cf-4314-a7dd-5855e752594b now=2014-11-11T18:05:15+00:00
at=finish method=GET path=/not_found status=404 size#bytes=6212 route_signature=/not_found elapsed=0.001 request_id=f3085630-05cf-4314-a7dd-5855e752594b now=2014-11-11T18:05:15+00:00
```

Response:
```json
{
  "error": {
    "type": "NotFound",
    "message": "y u no here?",
    "backtrace": [
      "/Users/csquared/projects/jersey/examples/readme.ru:11:in `block in <class:API>'",
      "/Users/csquared/projects/jersey/.bundle/bundle/ruby/2.1.0/gems/sinatra-1.4.5/lib/sinatra/base.rb:1603:in `call'",
      ....
    ]
 }
}
```

Unified, strucutred error handling. Notice how all we needed to do was raise `NotFound`
and we get a 404 response code (in the server logs) and our error message as part of the JSON payload.

### `Jersey::API::EphKeyEnv`

Uses an ephemeral RSA key to expose endpoints that allow the server process
to load an ENV using end-to-end encryption.

#### Usage
This is itself a Jersy API, which is a sinatra Base.

That means you can mount it as a separate app in a `Rack::URLMap` or `Rack::Cascade`,
or you can use it as a middleware.

For example:
```ruby
class API < Sinatra::Base
  use Jersey::API::EphKeyEnv
end

run Rack::Cascade.new([
  Jersey::API::EphKeyEnv,
  API
])

run Rack::URLMap.new(
  '/eph/' => Jersey::API::EphKeyEnv,
  '/' => API
)
```

#### `Jersey::HTTP::Errors`

Includes Ruby `Error` objects named with camel case for all of the HTTP 4xx and 5xx
errors. This allows you to raise `NotFound` as an error that has the `STATUS_CODE`
defined.

Allows uniform HTTP error handling when combined with the `ErrorHandler` sinatra extension.

#### Usage
Mix-in to any class that wants to raise HTTP errors, usually an API class.

```ruby
class API < Sinatra::Base
  include Jersey::HTTP::Errors
end
```

### `Jersey::Extensions::ErrorHandler`

Unifies error responses. If the error object's class has a `STATUS_CODE` defined (such as the
errors in `Jersey::HTTP::Errors`), this will use that as the HTTP return status. The error
message and backtraces are included in responses assuming that this in for an internal API
over secured channels and therefore favors ease of debugging over the security risk of
including the backtrace. This is something I may want to configure.

#### Usage
Register as a Sinatra extension

```ruby
class API < Sinatra::Base
  register Jersey::Extensions::ErrorHandler
end
```

#### `Jersey::Extensions::RouteSignature`
Adds a `ROUTE_SIGNATURE` to the `env` for each request, which is the name of an api endpoint
as it is *defined* versus the path that reaches your app.
For example, when you define a route such as ` get "/hello/:id"`, the `ROUTE_SIGNATURE` would
equal `"/hello/:id"`.
When combined with the `RequestLogger`,
it greatly simplifies creating aggregate statistics about the traffic hitting various api endpoints.

*Note:* this is considered a hack and something that sinatra should, but does not, handle.

#### Usage
Register as a Sinatra extension

```ruby
class API < Sinatra::Base
  register Jersey::Extensions::RouteSignature
end
```

#### `Jersey::Middleware::RequestID`

Creates a random request id for every http request, stored both in thread local storage
via the `RequestStore` and in the Rack `env`.


Works with or without explicitly including `RequestStore::Middleware`.

#### Usage
Use as a Rack middleware

```ruby
class API < Sinatra::Base
  use Jersey::Middleware::RequestID
end
```

#### `Jersey::Middleware::RequestLogger`

Logs http start and finish and errors in a structured logging format.

It defaults to using the `Jersey.logger` singleton which is `RequestStore`-aware.
Anything in `RequestStore[:log]` will get appended to the log data. (This is how request ids
are made available to logger calls outside of HTTP blocks but within HTTP request lifecycles).

Because I think request_ids are important, the logger will try to get them from either the
`RequestStore` or the `env`.

Logs at request start:

    at:              "start",
    request_id:      env['REQUEST_ID'],
    method:          request.request_method,
    path:            request.path_info,
    content_type:    request.content_type,
    content_length:  request.content_length

Logs at request finish:

    at:              "finish",
    method:          request.request_method,
    path:            request.path_info,
    status:          status,
    content_length:  headers['Content-Length'],
    route_signature: env['ROUTE_SIGNATURE'],
    elapsed:         (Time.now - @request_start).to_f,
    request_id:      env['REQUEST_ID']


#### Usage
Use as a Rack middleware

```ruby
class API < Sinatra::Base
  use Jersey::Middleware::RequestLogger
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jersey'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jersey


## Contributing

1. Fork it ( https://github.com/[my-github-username]/jersey/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
