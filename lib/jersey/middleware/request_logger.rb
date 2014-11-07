module Jersey::Middleware
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
end
