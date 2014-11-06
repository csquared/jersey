module Jersey::Extensions
  module RouteSignature
    def self.registered(app)
      app.helpers do
        def route_signature
          env["ROUTE_SIGNATURE"]
        end
      end
    end

    def route(verb, path, *)
      condition { env["ROUTE_SIGNATURE"] = path.to_s }
      super
    end
  end
end
