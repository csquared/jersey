require_relative 'helper'

class JerseyApiTest < ApiTest
  class SimpleApi < Jersey::API::Base
  end

  def app
    SimpleApi
  end
end
