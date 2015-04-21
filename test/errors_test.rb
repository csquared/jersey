require_relative 'helper'

class ErrorsTest < ApiTest
  class App < Jersey::API::Base
    get '/test-409' do
      raise Conflict, "bad"
    end

    get '/test-500' do
      raise InternalServerError, "bad"
    end

    get '/test-400' do
      raise BadRequest, "bad request"
    end

    get '/test-runtime-error' do
      raise "boom!"
    end
  end

  def test_not_found
    get '/not-found'
    assert_equal(404, last_response.status)
    assert_equal('NotFound', json['error']['type'])
  end

  def test_http_errors_400
    get '/test-400'
    assert_equal(400, last_response.status)
    assert_equal('BadRequest', json['error']['type'])
    assert_equal('bad request', json['error']['message'])
    assert(json['error']['request_id'])
  end

  def test_http_errors_409
    get '/test-409'
    assert_equal(409, last_response.status)
    assert_equal('Conflict', json['error']['type'])
    assert_equal('bad', json['error']['message'])
    assert(json['error']['request_id'])
  end

  def test_http_errors_500
    get '/test-500'
    assert_equal(500, last_response.status)
    assert_equal('InternalServerError', json['error']['type'])
    assert_equal('bad', json['error']['message'])
    assert(json['error']['request_id'])
  end

  def test_http_errors_Undefined
    get '/test-runtime-error'
    assert_equal(500, last_response.status)
    assert_equal('RuntimeError', json['error']['type'])
    assert_equal('boom!', json['error']['message'])
    assert(json['error']['request_id'])
  end

  def test_errors_are_logged
    Jersey.logger.stream = StringIO.new
    get '/test-500'
    loglines = logs.lines
    assert_equal(2, loglines.size)
    logdata = Logfmt.parse(loglines[0])
    assert(logdata['at'], 'started')
    logdata = Logfmt.parse(loglines[1])
    assert(logdata['at'], 'finished')
    assert(logdata['status'], '500')
  end
end
