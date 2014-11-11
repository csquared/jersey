require "sinatra/base"
require 'sinatra/json'
require 'json'
require 'request_store'

# jersey
require 'jersey/http_errors'
require 'jersey/middleware/request_id'
require 'jersey/middleware/request_logger'
require 'jersey/extensions/route_signature'
require 'jersey/extensions/error_handler'
require 'jersey/helpers/log'

module Jersey::API
  class Base < Sinatra::Base
    include Jersey::HTTP::Errors

    register Jersey::Extensions::RouteSignature
    register Jersey::Extensions::ErrorHandler

    use Jersey::Middleware::RequestID
    use Jersey::Middleware::RequestLogger
    use Rack::Deflater

    use Rack::ETag
    use Rack::ConditionalGet

    helpers Sinatra::JSON
    helpers Jersey::Helpers::Log
  end
end
