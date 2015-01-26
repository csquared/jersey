module Jersey
  module Logging
    # log who is calling you
    module LogCaller
      attr_accessor :frame_offset

      def frame_offset
        @frame_offset || 4
      end

      def log(hash = {})
        location = caller_locations(frame_offset).first
        super(hash.merge(
          caller: location.base_label,
          :"caller.line" => location.lineno,
          :"caller.file" => location.path
        ))
      end
    end

    # always log the time
    module LogTime
      def log(hash = {})
        super(hash.merge(now: Time.now))
      end
    end

    # only log the first ten lines of a backtrace so error logs
    # are digestible
    module LogError
      def log(loggable = {})
        case loggable
        when Hash
          super(loggable)
        when Exception
          e = loggable
          super(error: true, id: e.object_id, message: e.message)
          lineno = 0
          e.backtrace[0,10].each do |line|
            lineno += 1
            super(error: true,
                  id: e.object_id,
                  backtrace: line,
                  line_number: lineno)
          end
        end
      end
    end
  end
end
