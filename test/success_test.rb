require_relative 'helper'

class SuccessTest < ApiTest
  class App < Jersey::API::Base
    get '/test-201' do
      created({foo: 'baz'})
    end

    get '/test-202' do
      accepted({foo: 'bar'})
    end

    get '/test-204' do
      no_content
    end
  end

  def test_created
    get '/test-201'
    assert_equal(201, last_response.status)
    assert_equal('baz', json['foo'])
  end

  def test_accepted
    get '/test-202'
    assert_equal(202, last_response.status)
    assert_equal('bar', json['foo'])
  end

  def test_no_content
    get '/test-204'
    assert_equal(204, last_response.status)
    assert_equal('', last_response.body)
  end
end
