require 'request_store'

module Jersey
  module API
    module Middleware
    end

    module Extensions
    end

    module Helpers
    end

    module HTTP
    end
  end
end

# jersey
require 'jersey/http_errors'
require 'jersey/middleware/request_id'
require 'jersey/middleware/error_handler'
require 'jersey/middleware/request_logger'
require 'jersey/middleware/auto_json'
require 'jersey/extensions/route_signature'
require 'jersey/helpers/auto_json_params'
require 'jersey/helpers/log'
require 'jersey/helpers/success'
