module Jersey
  class BaseLogger
    attr_accessor :stream, :defaults

    def initialize(stream = $stdout, defaults = {})
      @defaults = defaults
      @stream = stream
    end

    def <<(data)
      @defaults.merge!(data)
    end

    def reset!
      @defaults = {}
    end

    def log(data, &block)
      log_to_stream(stream, @defaults.merge(data), &block)
    end

    private
    def log_to_stream(stream, data, &block)
      unless block
        str = unparse(data.merge(now: Time.now))
        stream.print(str + "\n")
      else
        data = data.dup
        start = Time.now
        log_to_stream(stream, data.merge(at: "start"))
        begin
          res = yield
          log_to_stream(stream, data.merge(
            at: "finish", elapsed: (Time.now - start).to_f))
          res
        rescue
          log_to_stream(stream, data.merge(
            at: "exception", elapsed: (Time.now - start).to_f))
          raise
        end
      end
    end

    def unparse
      raise "Need to subclass and implement #unparse"
    end
  end
end
