require mp_path('lib/templates/render')
require mp_path('mp/sinatra/helpers')

module MP
  module Templates
    module RendererHelper
      include MP::SinatraHelpers::AppContext
      include MP::Auth::Helpers
      include MP::SinatraHelpers::Debug
      include MP::SinatraHelpers::Gravatar

      def url_for(name, params = {})
        appcontext.url_for(name, params).untaint
      end

      def user_gravatar(user)
        gravatar(user.email).untaint
      end

      def fmt_datetime(dt)
        return (dt.nil?) ? '' : dt.strftime("%m/%d/%y %H:%M")
      end
    end

    class Renderer < Fiasco::Render
      include RendererHelper
    end

    class TemplateMgr
      def initialize(templates_path)
        @renderer = Renderer.new

        macros_path = File.join(templates_path, 'macros')

        # Declare templates
        Dir[File.join(templates_path, '**/*.html')].reject do |f|
          f[%r{^#{macros_path}}]
        end.each do |path|
          name = path.gsub(/\.html$/, '').gsub(templates_path, '')
          @renderer.declare(name, path: path)
        end
        # Declare macros
        Dir[File.join(macros_path, '**/*.html')].each do |path|
           @renderer.load_macros(path: path)
        end
      end

      def render(name, context)
        @renderer.render(name, context)
      end
    end
  end
end
