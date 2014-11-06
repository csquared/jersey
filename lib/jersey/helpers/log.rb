module Jersey::Helpers
  module Log
    def log(*args)
      env['logger'].log(*args)
    end
  end
end
