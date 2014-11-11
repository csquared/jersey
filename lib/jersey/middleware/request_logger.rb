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
      @logger.log(
        at:              "start",
        method:          request.request_method,
        path:            request.path_info,
        request_id:      env['REQUEST_ID']
      )
      status, headers, response = @app.call(env)
      @logger.log(
        at:              "finish",
        method:          request.request_method,
        path:            request.path_info,
        status:          status,
        'size#bytes' =>  headers['Content-Length'] || reaponse.size,
        route_signature: env['ROUTE_SIGNATURE'],
        elapsed:         (Time.now - @request_start).to_f,
        request_id:      env['REQUEST_ID']
      )
      @logger.reset!(:request_id)
      [status, headers, response]
    end
  end
end
