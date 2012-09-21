require mp_path('mp/forms/categories')

module MP
  module Routes
    CategoriesResource = MP::Routes::Generic::resource_factory(
      resource_name: :category,
      base_url: '/category',
      model_class: Category,
      template_path: 'categories',
      form_class: MP::Forms::CategoryForm,
      resource_name_plural: :categories
    )

    class Categories < CategoriesResource
      register Generic::ResourceListRoutes
      register Generic::ResourceNewRoutes
      register Generic::ResourceEditRoutes

      def authorize!
        admin_required!
      end
    end
  end

  Main.use Routes::Categories
end
