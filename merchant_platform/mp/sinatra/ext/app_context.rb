module MP
  module SinatraExt
    module AppContext

      def self.registered(app)
        app.before { (Thread.current[:__appcontext__] ||= []).push(self) }
        app.after { Thread.current[:__appcontext__].pop }
      end

    end
  end
end
