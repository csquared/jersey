require "sinatra/base"
require 'sinatra/json'
require 'json'

# Take over Sinatra's NotFound so we don't have to deal with the
# not_found block and can raise our own NotFound error
::Sinatra.send(:remove_const, :NotFound)
::Sinatra.const_set(:NotFound, ::Jersey::HTTP::Errors::NotFound)

module Jersey::API
  class Composable < Sinatra::Base
    include Jersey::HTTP::Errors
    use Jersey::Middleware::ErrorHandler

    def self.standalone!
      register Jersey::Extensions::RouteSignature

      use Rack::Deflater
      use Rack::ConditionalGet
      use Rack::ETag

      use Jersey::Middleware::RequestID
      use Jersey::Middleware::RequestLogger
      use Jersey::Middleware::ErrorHandler

      helpers Sinatra::JSON
      helpers Jersey::Helpers::Log
      helpers Jersey::Helpers::Success

      set :dump_errors, false
      set :raise_errors, true
      set :show_exceptions, false
      self
    end
  end

  class Base < Composable
  end
  Base.standalone!
end
