require_relative 'helper'
require 'jersey/eph_key_env'

class SuccessTest < ApiTest
  class App < Jersey::API::Base
    use Jersey::API::EphKeyEnv

    get '/foo' do
      ENV['FOO']
    end
  end

  def test_GET_pubkey_returns_one_pubkey
    get '/pubkey'
    pubkey = last_response.body
    OpenSSL::PKey::RSA.new(pubkey.unpack("m0")[0])

    get '/pubkey'
    pubkey2 = last_response.body
    assert_equal(pubkey, pubkey2)
  end

  def test_load_env_with_vault
    get '/pubkey'
    pubkey  = last_response.body
    rsa_key = OpenSSL::PKey::RSA.new(pubkey.unpack("m0")[0])
    blob = JSON.generate("FOO" => "bar")
    cipher_json = VaultCrypt.encrypt(blob, [rsa_key.public_key])

    get '/foo'
    assert_equal('', last_response.body)

    post '/msg/env', cipher_json
    assert_equal(200, last_response.status)
    assert_equal('OK', last_response.body)

    get '/foo'
    assert_equal('bar', last_response.body)
    ENV.delete('FOO')
  end

  def test_load_env_with_bad_pubkey
    rsa_key = OpenSSL::PKey::RSA.generate(1024)
    blob = JSON.generate("FOO" => "bar")
    cipher_json = VaultCrypt.encrypt(blob, [rsa_key.public_key])

    post '/msg/env', cipher_json
    assert_equal(400, last_response.status)
  end
end
