require_relative 'helper'

class ErrorsTest < ApiTest
  class App < Jersey::API::Base
    post '/test-params' do
      "#{params['one']}:#{params['two']}"
    end

    post '/test-json' do
      "#{request.json['one']}:#{request.json['two']}"
    end

    post "/test-array" do
      request.json.join(":")
    end

    post "/test-array-params" do
      params[0]
    end

    post "/test-auto-parse-fail" do
      request.body.read
    end
  end

  def test_form_encoded
    post('/test-params', one: "bar")
    assert_equal(200, last_response.status)
    assert_equal("bar:", last_response.body)
  end

  def test_json
    post('/test-params', {one: "bar"}.to_json)
    assert_equal(200, last_response.status)
    assert_equal("bar:", last_response.body)
  end

  def test_precedence
    post('/test-params?one=foo', one: "bar")
    assert_equal(200, last_response.status)
    assert_equal("bar:", last_response.body)
  end

  def test_body_with_json
    post('/test-params?two=foo', {one: "bar"}.to_json)
    assert_equal(200, last_response.status)
    assert_equal("bar:foo", last_response.body)
  end

  def test_query_string
    post('/test-params?one=bar')
    assert_equal(200, last_response.status)
    assert_equal("bar:", last_response.body)
  end

  def test_an_array
    post('/test-array', ['foo', 'bar'].to_json)
    assert_equal(200, last_response.status)
    assert_equal("foo:bar", last_response.body)
  end

  def test_an_array_from_params
    post('/test-array-params', ['foo', 'bar'].to_json)
    assert_equal(200, last_response.status)
    assert_equal("foo", last_response.body)
  end

  def test_passes_through_auto_parse_fails
    post('/test-auto-parse-fail', "{ HAHA")
    assert_equal(200, last_response.status)
    assert_equal("{ HAHA", last_response.body)
  end

  def test_query_string_and_body
    post('/test-params?one=bar', {two: "foo"}.to_json)
    assert_equal(200, last_response.status)
    assert_equal("bar:foo", last_response.body)
  end
end
