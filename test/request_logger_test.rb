require 'helper'

class RequestLoggerTest < ApiTest
  class App < Sinatra::Base
    use Jersey::Middleware::RequestLogger

    get('/get')  { 'OK' }
    post('/') { 'OK' }
    put('/')  { status(201); 'OK' }
    delete('/')  { 'OK' }
  end

  def setup
    super
    Jersey.logger.stream = StringIO.new
  end

  def test_logs_GET_request_method_path_and_time
    get '/get'
    loglines = logs.lines
    logdata = Logfmt.parse(loglines[0])
    assert_equal('start', logdata['at'])
    assert_equal('GET', logdata['method'])
    assert_equal('/get', logdata['path'])
    assert(logdata['now'], 'must log time')

    logdata = Logfmt.parse(loglines[1])
    assert_equal('finish', logdata['at'])
    assert_equal('GET', logdata['method'])
    assert_equal('/get', logdata['path'])
    assert_equal(200, logdata['status'])
    assert_equal(2, logdata['size#bytes'])
    assert(logdata['now'], 'must log time')
    assert(logdata['elapsed'], 'must log duration')
  end

  def test_logs_POST_request_method_path_and_time
    post '/'
    logdata = Logfmt.parse(logs.lines[0])
    assert_equal('POST', logdata['method'])
    assert_equal('/', logdata['path'])
  end

  def test_logs_PUT_request_method_path_and_time
    put '/'
    logdata = Logfmt.parse(logs.lines[0])
    assert_equal('PUT', logdata['method'])

    logdata = Logfmt.parse(logs.lines[1])
    assert_equal('PUT', logdata['method'])
    assert_equal(201, logdata['status'])
  end
end

class RequestLoggerWithRequestIDsTest < ApiTest
  class App < Sinatra::Base
    use Jersey::Middleware::RequestID
    use Jersey::Middleware::RequestLogger

    get('/') do
      Jersey.log(at: 'mid-request')
      'OK'
    end
  end

  def setup
    super
    Jersey.logger.stream = StringIO.new
  end

  # Testing a few things here
  def test_logs_request_id
    get '/'
    loglines = logs.lines

    logdata = Logfmt.parse(loglines[0])
    request_id = logdata['request_id']
    assert_equal('start', logdata['at'])
    assert(request_id, 'must log request id')

    logdata = Logfmt.parse(loglines[1])
    assert_equal('mid-request', logdata['at'])
    assert_equal(request_id, logdata['request_id'])

    logdata = Logfmt.parse(loglines[2])
    assert_equal('finish', logdata['at'])
    assert_equal(request_id, logdata['request_id'])

  end

  def test_doesnt_persist_request_id
    get '/'
    logdata = Logfmt.parse(logs.lines[0])
    request_id = logdata['request_id']

    get '/'
    logdata = Logfmt.parse(logs.lines[3])
    refute_equal(request_id, logdata['request_id'])
  end

  def test_doesnt_clear_everything
    Jersey.logger << {app_name: 'hotness'}
    get '/'
    logdata = Logfmt.parse(logs.lines[0])
    assert_equal('hotness', logdata['app_name'])

    get '/'
    logdata = Logfmt.parse(logs.lines[3])
    assert_equal('hotness', logdata['app_name'])
  end
end
