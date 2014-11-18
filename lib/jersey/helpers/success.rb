module Jersey::Helpers
  module Success
    def created(*args)
      status(201)
      json(*args)
    end

    def accepted(*args)
      status(202)
      json(*args)
    end

    def no_content(*args)
      status(204)
    end
  end
end
