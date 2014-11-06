require 'sinatra'
require 'sinatra/json'

module Jersey::API
  class Base < Sinatra::Base
    include Jersey::HTTP::Errors

#   register Pliny::Extensions::Instruments
 #  use Pliny::Middleware::RequestID
 #  use Pliny::Middleware::Timeout

    helpers Sinatra::JSON

    set :dump_errors, false
    set :raise_errors, false
    set :show_exceptions, false

    # APIS should always return meaningful standardized errors
    # with statuses that best match HTTP conventions
    #
    # Places nicely with Jersey::HTTP::Errors
    error do
      content_type(:json)
      e = env['sinatra.error']
      # get status code from Jersey Errors
      if e.class.const_defined?(:STATUS_CODE)
        status(e.class::STATUS_CODE)
      else
        status(500)
      end

      json(error: {
        type: e.class.name.split('::').last,
        message: e.message,
        backtrace: e.backtrace
      })
    end
  end
end
