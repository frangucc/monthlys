module RecurlyHelpers
  module ErrorsHandler
    def add_recurly_errors(recurly_resource)
      recurly_resource.errors.each do |field, error|
        self.errors.add(field, error.join(' '))
      end
    end
  end
end
