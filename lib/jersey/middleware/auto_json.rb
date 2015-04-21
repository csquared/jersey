# Detects json by customizable regex and
# by looking for request bodies that being with
# '{' or '['
#
# Sets `rack.json` on rack env, but leaves
# other vars alone.
module Jersey::Middleware
  class AutoJson
    JSON_PARSER = lambda { |data| JSON.parse(data) }
    JSON_REGEX = /json/

    # Configure the :porser and the :json_regex though
    # if you're going to be strict about this you
    # probably shouldn't be using this middleware
    def initialize(app, options = {})
      @app = app
      @parser = options.delete(:parser) || JSON_PARSER
      @json_regex = options.delete(:json_regex) || JSON_REGEX
    end

    # Make json happen.
    def call(env)
      req = Rack::Request.new(env)
      type = req.media_type
      if type && type.match(@json_regex)
        # raise error if parsing declared json
        begin
          env['rack.json'] = @parser.call(req.body.read)
        rescue => ex
          raise Jersey::HTTP::Errors::BadRequest, "json parse error in AutoJson: #{ex.message}"
        end
      elsif ["{","["].include?(req.body.read(1))
        # make best effort to parse what looks like json
        req.body.rewind
        env['rack.json'] = @parser.call(req.body.read) rescue nil
      end
      req.body.rewind
      @app.call(env)
    end
  end
end

## Let's enable folks to use request.json
## in their rack apps
require 'rack/request'
class Rack::Request
  def json
    env['rack.json']
  end
end
