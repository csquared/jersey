# Need this so we load up .env.test
ENV['RACK_ENV'] = 'test'

# Requies all the Gems
require_relative '../lib/jersey'
Jersey.setup

# require test runner
require 'minitest/autorun'
require 'minitest/pride' # :)

# load the test helpers
# Dir["./test/helpers/**/*.rb"].sort.each { |f| require f }

module JsonHelpers
  def json; JSON.parse(last_response.body); end
end

class UnitTest < Minitest::Test
  def setup
    super
    Jersey.logger.reset!
    Jersey.logger.stream = StringIO.new unless ENV['LOG']
  end

  def logs
    Jersey.logger.stream.string
  end
end

class ApiTest < UnitTest
  include Rack::Test::Methods
  include JsonHelpers

  # default app method to return an app named `App`
  def app
    self.class.const_get(:App)
  end
end
