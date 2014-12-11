module Jersey::Middleware
  class ErrorHandler
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call(env)
      rescue => e
        # get status code from Jersey Errors
        if e.class.const_defined?(:STATUS_CODE)
          status = e.class::STATUS_CODE
        elsif e.respond_to?(:status_code)
          status = e.status_code
        else
          status = 500
        end

        headers = {
          'Content-Type' => 'application/json'
        }

        body = {error: {
          type: e.class.name.split('::').last,
          request_id: env['REQUEST_ID'] || env['HTTP_REQUEST_ID'],
          message: e.message,
          backtrace: e.backtrace
        }}.to_json

        [status, headers, [body]]
      end
    end
  end
end
