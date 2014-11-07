module Jersey
  class LogfmtLogger < BaseLogger
    private
    def unparse(attrs)
      attrs.map { |k, v| unparse_pair(k, v) }.compact.join(" ")
    end

    def quote_string(k, v)
      # try to find a quote style that fits
      if !v.include?('"')
        %{#{k}="#{v}"}
      elsif !v.include?("'")
        %{#{k}='#{v}'}
      else
        %{#{k}="#{v.gsub(/"/, '\\"')}"}
      end
    end

    def unparse_pair(k, v)
      v = v.call if v.is_a?(Proc)
      # only quote strings if they include whitespace
      if v == nil
        nil
      elsif v == true
        k
      elsif v.is_a?(Float)
        "#{k}=#{format("%.3f", v)}"
      elsif v.is_a?(String) && v =~ /\s/
        quote_string(k, v)
      elsif v.is_a?(Time)
        "#{k}=#{v.iso8601}"
      else
        "#{k}=#{v}"
      end
    end
  end
end
