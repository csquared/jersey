# NOTE: Work in progress!!
#
require 'json'
require 'jersey/vault_crypt'

module Jersey::API
  # Ephemeral-Key P2P Msg to enable
  # secure ENV loading
  #
  # requires 2 people to post env JSON blob, bitwize XORed
  # with a random number
  class TwoManEphKeyEnv < Composable
    @@loaded = false

    get '/pubkey/env' do
      if @@loaded
        raise BadRequest, "ENV already loaded"
      else
        public_key
      end
    end

    post '/msg/env' do
      if @@loaded
        raise BadRequest, "ENV already loaded"
      else
        # attempt decrypt and JSON parse
        begin
          request.body.rewind
          data = request.body.read
          naked_data = VaultCrypt.decrypt(data, rsa_key)
          combine(naked_data)
        rescue => e
          raise BadRequest.new(e)
        end
        'OK'
      end
    end

    if Config.test?
      def self.reset!
        @@loaded = @@rsa_key = @@public_key  = false
      end
    end

    def self.quit_after_load!
      @@quit_after_load = true
    end

    helpers do
      def rsa_key
        @@rsa_key ||= OpenSSL::PKey::RSA.generate(2048)
      end

      def public_key
        @@public_key ||= [rsa_key.public_key.to_der].pack("m0")
      end

      def combine(naked_data)
        if !@@data_fragment
          @@data_fragment = naked_data
        elsif @@data_fragment == naked_data
          raise "Already Loaded"
        elsif @@data_fragment != naked_data
          # NOTE: not sure if this works
          xored = s1.unpack('C*')
            .zip(s2.unpack('C*'))
            .map{ |a,b| a ^ b }.pack('C*')

          env_data = JSON.parse(xored)
          env_data.each do |key, value|
            ENV[key] = value
          end
          @@loaded = true
        end
        # load env data
        if @@quit_after_load
          self.class.quit!
        end
      end
    end
  end
end
