module Jersey::Middleware
  # Logs request info using the configured logger or the Jersey singleton
  #
  # Adds request_id to the default logger params
  class RequestLogger
    def initialize(app, options={})
      @app = app
      @logger = options[:logger] || Jersey.logger
    end

    def call(env)
      @request_start = Time.now
      request = Rack::Request.new(env)
      start_data = {
        at:              "start",
        request_id:      env['REQUEST_ID'],
        method:          request.request_method,
        path:            request.path,
        content_type:    request.content_type,
        content_length:  request.content_length
      }
      @logger.log(start_data)
      status, headers, response = @app.call(env)
      @logger.log(
        at:              "finish",
        method:          request.request_method,
        path:            request.path,
        status:          status,
        content_length:  headers['Content-Length'],
        route_signature: env['ROUTE_SIGNATURE'],
        elapsed:         (Time.now - @request_start).to_f,
        request_id:      env['REQUEST_ID']
      )
      @logger.reset!(:request_id)
      [status, headers, response]
    end
  end
end
