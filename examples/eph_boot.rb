require 'jersey'
Jersey.setup
require 'jersey/eph_key_env'
Jersey::API::EphKeyEnv.port = ENV['PORT'] || 8000
Jersey::API::EphKeyEnv.standalone!
Jersey::API::EphKeyEnv.quit_after_load!
Jersey::API::EphKeyEnv.run!
puts ENV["FOO"]
