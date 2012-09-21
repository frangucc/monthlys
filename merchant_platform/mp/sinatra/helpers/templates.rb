module MP
  module SinatraHelpers
    module Templates

      def render(name, context = {})
        MP::Main::TPL.render(name, context)
      end

    end
  end
end
