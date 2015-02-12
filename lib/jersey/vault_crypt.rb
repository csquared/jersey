require 'securerandom'
require 'openssl'
require 'digest'
require 'json'

module VaultCrypt
  CIPHER_NAME = "AES-256-CBC"
  IV_LENGTH = 16

  def aes_encrypt(data)
    cipher = OpenSSL::Cipher.new(CIPHER_NAME).encrypt
    cipher.iv = iv = SecureRandom.random_bytes(IV_LENGTH)
    cipher.key = key = cipher.random_key
    encrypted = cipher.update(data) + cipher.final
    [iv, key, encrypted]
  end

  def aes_decrypt(encrypted_data, iv, key)
    cipher = OpenSSL::Cipher.new(CIPHER_NAME).decrypt
    cipher.iv  = iv
    cipher.key = key
    cipher.update(encrypted_data) + cipher.final
  end

  def encrypt(data, public_keys)
    aes_iv, aes_key, aes_blob = aes_encrypt(data)
    aes_blob_hash = Digest::SHA256.digest(aes_blob)
    key_blob = [aes_iv, aes_key, aes_blob_hash].join

    recipients = {}
    public_keys.each{|public_key| recipients[ [public_key.to_der].pack("m0") ] = [public_key.public_encrypt(key_blob)].pack("m0") }

    JSON.pretty_generate({ blob: [aes_blob].pack("m0"), recipients: recipients })
  end

  def decrypt(json, privkey)
    json = JSON.parse(json)
    key_blob = json['recipients'].find{|k,v| k == [privkey.public_key.to_der].pack("m0") }.last.unpack("m0")[0] rescue (return nil)
    aes_iv, aes_key, aes_blob_hash = privkey.private_decrypt(key_blob).unpack("a16a32a32") rescue (return nil)

    blob = json['blob'].unpack("m0")[0]
    if Digest::SHA256.digest(blob) == aes_blob_hash
      aes_decrypt(blob, aes_iv, aes_key)
    end
  end

  extend self
end
