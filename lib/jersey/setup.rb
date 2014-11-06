require 'env-conf'

module Jersey
  #require bundler and the proper gems for the ENV
  def self.require
    Kernel.require 'bundler'
    Config.dotenv!
    $stderr.puts "Loading #{Config.app_env} environment..."
    Bundler.require(:default, Config.app_env)
  end

  # adds ./lib dir to the load path
  def self.load_path
    $stderr.puts "Adding './lib' to path..."
    $LOAD_PATH.unshift(File.expand_path('./lib'))
  end

  # sets TZ to UTC and Sequel timezone to :utc
  def self.set_timezones
    $stderr.puts "Setting timezones to UTC..."
    Sequel.default_timezone = :utc if defined? Sequel
    ENV['TZ'] = 'UTC'
  end

  def self.hack_time_class
    $stderr.puts "Modifying Time#to_s to use #iso8601..." if ENV['DEBUG']
    # use send to call private method
    Time.send(:define_method, :to_s) do
      self.iso8601
    end
  end

  # all in one go
  def self.setup
    self.require
    self.load_path
    self.set_timezones
    self.hack_time_class
  end
end
