require 'jersey'
Jersey.setup
require 'jersey/eph_key_env'

class EnvAPI < Jersey::API::Base
  use Jersey::API::EphKeyEnv

  get '/env' do
    Jersey.log(at: "env")
    ENV["FOO"].to_s
  end
end

run EnvAPI
