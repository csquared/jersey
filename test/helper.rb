# Need this so we load up .env.test
ENV['RACK_ENV'] = 'test'

# Requies all the Gems
require_relative '../lib/jersey'
Jersey.setup

# require test runner
require 'minitest/autorun'
require 'minitest/pride' # :)

Dir["./test/helpers/**/*.rb"].sort.each { |f| require f }

module JsonHelpers
  def json; JSON.parse(last_response.body); end
end

class UnitTest < Minitest::Test
  def setup
    super
#    DatabaseCleaner.start
#    Pliny.stdout = StringIO.new unless ENV['LOG']
  end

  def teardown
    super
#    DatabaseCleaner.clean
  end
end

class ApiTest < UnitTest
  include Rack::Test::Methods
  include JsonHelpers
end
