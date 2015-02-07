module Jersey::Helpers
  module AutoJsonParams
    # Merges sinatra @params Hash with
    # json data parsed by a rack middleware
    # that has set `rack.json` on the rack env.
    #
    # If the parsed data is an array, merges by
    # using the array index as a hash key.
    #
    # Json data gets precendence in naming collisions
    def params
      # we have parsed json!
      if @env['rack.json']
        json = @env['rack.json']
        if json.is_a?(Hash)
          # merge with params
          super.merge(json)
        else
          # covert array to hash by index
          zipped = json.each_with_index
          zipped = zipped.to_a.map(&:reverse)
          super.merge(Hash[zipped])
        end
      else
        super
      end
    end
  end
end
