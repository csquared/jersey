require 'jersey/logging/base_logger'
require 'jersey/logging/logfmt_logger'
require 'jersey/logging/json_logger'
require 'jersey/logging/mixins'

module Jersey
  class Logger < LogfmtLogger
    include Logging::LogTime
    include Logging::LogError
  end

  module LoggingSingleton
    def logger
      @logger ||= Jersey::Logger.new
    end

    def stream
      logger.stream
    end

    def stream=(other)
      logger.stream=other
    end

    def log(loggable = {})
      logger.log(loggable)
    end
  end

  extend LoggingSingleton
end
