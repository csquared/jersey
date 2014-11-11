module Jersey
  class BaseLogger
    attr_accessor :stream, :defaults

    def initialize(opts = {})
      @stream   = opts.fetch(:stream, $stdout)
      @defaults = opts.fetch(:defaults, {})
    end

    def <<(data)
      @defaults.merge!(data)
    end

    def reset!(key = nil)
      if key
        @defaults.delete(key)
        @defaults.delete(key.to_sym)
      else
        @defaults.clear
      end
    end

    def log(data, &block)
      log_to_stream(stream, @defaults.merge(data), &block)
    end

    private
    def log_to_stream(stream, data, &block)
      data.merge!(request_data || {})
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

    def request_data
      RequestStore[:log] if defined? RequestStore
    end
  end
end
