module Jersey
  class JSONLogger < BaseLogger
    private
    def unparse(attrs)
      attrs.to_json
    end
  end
end
