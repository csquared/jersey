require "sinatra/base"
require 'sinatra/json'
require 'json'

# Take over Sinatra's NotFound so we don't have to deal with the
# not_found block and can raise our own NotFound error
::Sinatra.send(:remove_const, :NotFound)
::Sinatra.const_set(:NotFound, ::Jersey::HTTP::Errors::NotFound)

module Jersey::API
  class Base < Sinatra::Base
    include Jersey::HTTP::Errors

    register Jersey::Extensions::RouteSignature

    use Jersey::Middleware::ErrorHandler
    use Rack::Deflater
    use Rack::ConditionalGet
    use Rack::ETag

    use Jersey::Middleware::RequestID
    use Jersey::Middleware::RequestLogger

    helpers Sinatra::JSON
    helpers Jersey::Helpers::Log
    helpers Jersey::Helpers::Success

    set :dump_errors, false
    set :raise_errors, true
    set :show_exceptions, false
  end
end
