require 'jersey/logging/base_logger'
require 'jersey/logging/logfmt_logger'
require 'jersey/logging/json_logger'
require 'jersey/logging/mixins'

module Jersey
  class Logger < LogfmtLogger
    include Logging::LogTime
    include Logging::LogError
  end

  class JsonLogger < JSONLogger
    include Logging::LogTime
    include Logging::LogError
  end

  module LoggingSingleton
    attr_writer :logger

    def logger
      @logger ||= Jersey::Logger.new
    end

    def log(loggable = {})
      logger.log(loggable)
    end
  end

  extend LoggingSingleton
end
