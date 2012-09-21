module MP
  module SinatraHelpers
    module AppContext

      def appcontext
        Thread.current[:__appcontext__].last
      end

    end
  end
end
