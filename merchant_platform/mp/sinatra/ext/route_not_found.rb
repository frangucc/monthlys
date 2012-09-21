module MP
  module SinatraExt
    module RouteNotFound

      def self.registered(app)
        app.not_found do
          if request.path[-1, 1] != '/'
            redirect request.path + '/'
          else
            status 404
          end
        end
      end

    end
  end
end
