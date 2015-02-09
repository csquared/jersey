require 'jersey'
Jersey.setup
require 'jersey/eph_key_env'
Jersey::API::EphKeyEnv.one_time_load!(port: 8000)
puts ENV["FOO"]
