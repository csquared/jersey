require 'json'
require 'jersey/vault_crypt'

module Jersey::API
  # Ephemeral-Key P2P Msg to enable
  # secure ENV loading
  class EphKeyEnv < Composable
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
          env_data = JSON.parse(naked_data)
        rescue => e
          raise BadRequest.new(e)
        end

        # load env data
        env_data.each do |key, value|
          ENV[key] = value
        end
        @@loaded = true
        'OK'
      end
    end

    if Config.test?
      def self.reset!
        @@loaded = @@rsa_key = @@public_key  = false
      end
    end

    helpers do
      def rsa_key
        @@rsa_key ||= OpenSSL::PKey::RSA.generate(2048)
      end

      def public_key
        @@public_key ||= [rsa_key.public_key.to_der].pack("m0")
      end
    end
  end
end
