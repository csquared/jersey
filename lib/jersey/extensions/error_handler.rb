module Jersey::Extensions
  module ErrorHandler
    def self.registered(app)
      app.set :dump_errors, false
      app.set :raise_errors, false
      app.set :show_exceptions, false

      # APIS should always return meaningful standardized errors
      # with statuses that best match HTTP conventions
      #
      # Places nicely with Jersey::HTTP::Errors
      app.error do
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
end
