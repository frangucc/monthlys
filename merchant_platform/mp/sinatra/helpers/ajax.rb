module MP
  module SinatraHelpers
    module Ajax
      def json(value)
        content_type(:json)
        value.to_json
      end
    end
  end
end
