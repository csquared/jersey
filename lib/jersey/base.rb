require 'sinatra'
require 'sinatra/json'

require 'jersey/log'
require 'jersey/request_id'

class RequestLogger
  def initialize(app, options={})
    @app = app
    @logger = Jersey::LogfmtLogger.new
  end

  def call(env)
    @request_start = Time.now
    request = Rack::Request.new(env)
    @logger.log(
      at:              "start",
      request_id:      env['REQUEST_ID'],
      method:          request.request_method,
      path:            request.path_info
    )
    status, headers, response = @app.call(env)
    @logger.log(
      at:              "finish",
      method:          request.request_method,
      path:            request.path_info,
      status:          status,
      'size#bytes' =>  headers['Content-Length'] || reaponse.size,
      route_signature: env['ROUTE_SIGNATURE'],
      request_id:      env['REQUEST_ID'],
      elapsed:         (Time.now - @request_start).to_f
    )
    [status, headers, response]
  end
end

module RouteSignature
  def self.registered(app)
    app.helpers do
      def route_signature
        env["ROUTE_SIGNATURE"]
      end
    end
  end

  def route(verb, path, *)
    condition { env["ROUTE_SIGNATURE"] = path.to_s }
    super
  end
end

module Jersey::API
  class Base < Sinatra::Base
    include Jersey::HTTP::Errors

    register RouteSignature
    use RequestID
    use RequestLogger

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
