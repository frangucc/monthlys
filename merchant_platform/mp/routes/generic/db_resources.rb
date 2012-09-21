module MP
  module Routes
    module Generic

      def self.resource_factory(options)
        [:resource_name, :base_url, :model_class].each do |k|
          raise ArgumentError, "missing #{k}" unless options.include?(k)
        end

        options[:resource_name_plural] ||= "#{options[:resource_name]}s".to_sym

        options[:new_form_class] ||= options[:form_class]
        options[:edit_form_class] ||= options[:form_class]

        options[:redirect_path] ||= false
        options[:new_redirect_path] ||= options[:redirect_path]
        options[:edit_redirect_path] ||= options[:redirect_path]
        options[:delete_redirect_path] ||= options[:redirect_path]

        base_class = options.delete(:base_class) || MP::Routes::RoutesBase
        Class.new(base_class).tap do |c|
          c.send(:include, ResourceMixin)

          options.each do |k ,v|
            case v
            when Proc then c.set(k, proc{v}) # Don't use sinatra deferred settings
            else c.set(k, v)
            end
          end
        end
      end


      # Overridable options and hooks
      module ResourceMixin
        def template_path(name)
          "#{settings.template_path}/#{name}"
        end

        def model_class
          settings.model_class
        end

        def authorize!
          merchant_required!
        end

        def dataset
          model_class
        end

        def list_hook
        end

        def new_form_class
          settings.new_form_class
        end

        def edit_form_class
          settings.edit_form_class
        end

        def redirect_path(path = settings.redirect_path)
          if params[:next]
            params[:next]
          elsif path
            path = url_for(path) if path.is_a? Symbol
            path
          else
            url_for(:"#{settings.resource_name}_list")
          end
        end

        def find_record(param_key = nil)
          param_key ||= :id
          dataset.find([params[param_key]]).first or not_found
        end

        def find_record_or_404(param_key = nil)
          begin
            find_record(param_key)
          rescue ActiveRecord::RecordNotFound
            not_found
          end
        end

        def edit_context_hook(context)
          context
        end

        def new_context_hook(context)
          context
        end

        def view_context_hook(context)
          context
        end
      end


      # Routes


      module ResourceListRoutes
        def self.registered(app)
          url_for_index = app.url(:"#{app.resource_name}_list", "#{app.base_url}/")

          app.get url_for_index do
            authorize!

            page = paginate(dataset)
            items = page.delete(:items)

            list_hook

            render(template_path(:index), {
              app.resource_name_plural => items,
              page: page
            })
          end
        end

      end

      module ResourceViewRoutes
        def self.registered(app)
          url_for_view = app.url(:"#{app.resource_name}_view",
                                 "#{app.base_url}/:id/")

          app.get url_for_view do
            authorize!

            ctx = view_context_hook({ record: find_record_or_404 })
            render(template_path(:view), ctx)
          end
        end
      end


      module ResourceNewRoutes
        def self.registered(app)
          url_for_new = app.url(:"#{app.resource_name}_new",
                                "#{app.base_url}/new/")

          app.get url_for_new do
            authorize!
            ctx = new_context_hook({ form: app.new_form_class.new,
                                     edit: false })
            render(template_path(:edit), ctx)
          end

          app.post url_for_new do
            authorize!

            form = app.new_form_class.new(params)
            if form.valid?
              object = form.save(model_class.new)
              redirect(redirect_path(app.new_redirect_path))
            end

            ctx = new_context_hook({ form: form, edit: false })
            render(template_path(:edit), ctx)
          end
        end
      end


      module ResourceEditRoutes
        def self.registered(app)
          url_for_edit = app.url(:"#{app.resource_name}_edit",
                                 "#{app.base_url}/:id/")

          app.get url_for_edit do
            authorize!

            r = find_record_or_404
            form = app.edit_form_class.new(nil, record: r)

            ctx = edit_context_hook({ form: form,
                                      edit: true,
                                      record: r })
            render(template_path(:edit), ctx)
          end

          app.post url_for_edit do
            authorize!

            record = dataset.find(params[:id])
            form = app.edit_form_class.new(params, record: record)

            if form.valid?
              form.save(record)
              redirect(redirect_path(app.edit_redirect_path))
            end

            ctx = edit_context_hook({ form: form,
                                      edit: false,
                                      record: record })
            render(template_path(:edit), ctx)
          end
        end
      end


      module ResourceDeleteRoutes
        def self.registered(app)
          url_for_delete = app.url(:"#{app.resource_name}_delete",
                                   "#{app.base_url}/:id/delete/")

          app.get url_for_delete do
            authorize!
            record = find_record_or_404
            render(template_path(:delete), { app.resource_name => record })
          end

          app.delete url_for_delete do
            authorize!
            r = find_record_or_404
            r.destroy  # XXX: Is this enugh?
            redirect(redirect_path(app.delete_redirect_path))
          end
        end
      end

    end
  end
end
