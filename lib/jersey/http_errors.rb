module Jersey::HTTP
  module Errors
    HTTPError = Class.new(StandardError)
    ClientError = Class.new(HTTPError)
    ServerError = Class.new(HTTPError)

    # Define ALL the HTTP errors as constants
    FOUR_HUNDRED = [
      [400, 'BadRequest', :bad_request],
      [401, 'Unauthorized', :unauthorized],
      [402, 'PaymentRequired', :payment_required],
      [403, 'Forbidden', :forbidden],
      [404, 'NotFound', :not_found],
      [405, 'MethodNotAllowed', :method_not_allowed],
      [406, 'NotAcceptable', :not_acceptable],
      [407, 'ProxyAuthenticationRequired', :proxy_authentication_required],
      [408, 'RequestTimeout', :request_timeout],
      [409, 'Conflict', :conflict],
      [410, 'Gone', :gone],
      [411, 'LengthRequired', :length_required],
      [412, 'PreconditionFailed', :precondition_failed],
      [413, 'RequestEntityTooLarge', :request_entity_too_large],
      [414, 'RequestURITooLong', :request_uri_too_long],
      [415, 'UnsupportedMediaType', :unsupported_media_type],
      [416, 'RequestedRangeNotSatisfiable', :requested_range_not_satisfiable],
      [417, 'ExpectationFailed', :expectation_failed],
      [422, 'UnprocessableEntity', :unprocessable_entity],
      [423, 'Locked', :locked],
      [424, 'FailedDependency', :failed_dependency],
      [426, 'UpgradeRequired', :upgrade_required],
    ]

    FIVE_HUNDRED = [
      [500, 'InternalServerError', :internal_server_error],
      [501, 'NotImplemented', :not_implemented],
      [502, 'BadGateway', :bad_gateway],
      [503, 'ServiceUnavailable', :service_unavailable],
      [504, 'GatewayTimeout', :gateway_timeout],
      [505, 'HTTPVersionNotSupported', :http_version_not_supported],
      [507, 'InsufficientStorage', :insufficient_storage],
      [510, 'NotExtended', :not_extended],
    ]

    # Dynamically Create all the necessary HTTP errors
    # with appropriate status codes
    (FOUR_HUNDRED + FIVE_HUNDRED).each do |s|
      code, const_name, symbol = s[0],s[1],s[2]
      if code >= 500
        klass = Class.new(ServerError)
      else
        klass = Class.new(ClientError)
      end
      klass.const_set(:STATUS_CODE, code)
      const_set(const_name,klass)
    end
  end
end
